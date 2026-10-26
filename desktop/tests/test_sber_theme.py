#!/usr/bin/env python3
"""Isolated resource, format and failure-path tests for DESKTOP-001."""
import configparser
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True

SCRIPT = Path(__file__).resolve().parents[0] / 'tools/gen_sber_theme.py'
spec = importlib.util.spec_from_file_location('sber_theme', SCRIPT)
theme = importlib.util.module_from_spec(spec)
spec.loader.exec_module(theme)


class ThemeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.output = self.root / 'output'

    def test_source_rgba_and_foreground_compositing(self):
        self.assertEqual(theme.rgba('#171717F5'), (23, 23, 23, 245))
        self.assertEqual(theme.opaque(theme.rgba('#171717F5'), (247, 247, 248, 255)),
                         (32, 32, 32, 255))
        self.assertEqual(theme.opaque((0, 0, 0, 0), (247, 247, 248, 255)),
                         (247, 247, 248, 255))
        with self.assertRaises(ValueError):
            theme.rgba('[unresolved.reference.100]')

    def test_kde_rgb_opaque_and_both_modes(self):
        files = theme.generate(theme.DEFAULT_RESOURCES, self.output)
        self.assertEqual(len(files), 7)
        for mode in ('Light', 'Dark'):
            config = configparser.ConfigParser()
            config.read(self.output / f'kde/SberOS{mode}.colors')
            self.assertEqual(config['General']['Name'], f'SberOS{mode}')
            for section in config.sections():
                if section.startswith('Colors:') or section == 'WM':
                    for value in config[section].values():
                        channels = [int(c) for c in value.split(',')]
                        self.assertEqual(len(channels), 3)
                        self.assertTrue(all(0 <= c <= 255 for c in channels))
        self.assertNotEqual(files['kde/SberOSLight.colors'], files['kde/SberOSDark.colors'])
        self.assertEqual(files, theme.generate(theme.DEFAULT_RESOURCES, self.output))

    def test_resource_change_propagates_and_is_recorded(self):
        resources = self.root / 'resources'
        shutil.copytree(theme.DEFAULT_RESOURCES / 'theme', resources / 'theme')
        before = theme.generate(resources, self.output)
        source = resources / 'theme/colors/os/osSuperGray.json'
        data = json.loads(source.read_text())
        data['0'] = '#010203'
        source.write_text(json.dumps(data))
        after = theme.generate(resources, self.output)
        self.assertIn('BackgroundNormal=1,2,3', after['kde/SberOSLight.colors'])
        self.assertIn('@define-color window_bg_color #010203;',
                      after['gtk/light/gtk-4.0.css'])
        self.assertEqual(before['kde/SberOSDark.colors'], after['kde/SberOSDark.colors'])
        key = 'theme/colors/os/osSuperGray.json'
        self.assertNotEqual(json.loads(before['manifest.json'])['sources'][key],
                            json.loads(after['manifest.json'])['sources'][key])

    def test_invalid_dark_surface_writes_nothing(self):
        resources = self.root / 'resources'
        shutil.copytree(theme.DEFAULT_RESOURCES / 'theme', resources / 'theme')
        source = resources / 'theme/sdds_os.json'
        data = json.loads(source.read_text())
        data['Dark']['Background']['Default']['Primary'] = '#01020380'
        source.write_text(json.dumps(data))
        with self.assertRaisesRegex(ValueError, 'must be opaque'):
            theme.generate(resources, self.output)
        self.assertFalse(self.output.exists())

    def test_cli_does_not_write_user_profile(self):
        home = self.root / 'home'
        home.mkdir()
        import os
        env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(home / 'config'),
                   XDG_DATA_HOME=str(home / 'data'))
        result = subprocess.run([sys.executable, str(SCRIPT), '--output', str(self.output)],
                                env=env, capture_output=True, text=True, timeout=15)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(list(home.iterdir()), [])
        result = subprocess.run([sys.executable, str(SCRIPT), '--resources', str(home),
                                 '--output', str(self.root / 'bad')],
                                env=env, capture_output=True, text=True, timeout=15)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.root / 'bad').exists())


if __name__ == '__main__':
    unittest.main()
