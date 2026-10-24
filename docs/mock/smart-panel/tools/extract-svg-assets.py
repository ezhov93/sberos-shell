#!/usr/bin/env python3
"""Extract reusable art and source geometry from the supplied Pixso SVG exports.
Requires Pillow only for reducing embedded raster payloads; SVG paths stay vector.
Never writes into docs/sources/.
"""
from pathlib import Path
import base64
import copy
import hashlib
import io
import json
import re
import xml.etree.ElementTree as ET
from PIL import Image

ROOT = Path(__file__).resolve().parents[4]
SOURCE = ROOT / 'docs/sources/panel/svg'
OUTPUT = ROOT / 'docs/mock/smart-panel/assets'
SVG = 'http://www.w3.org/2000/svg'
XLINK = 'http://www.w3.org/1999/xlink'
ET.register_namespace('', SVG)
ET.register_namespace('xlink', XLINK)
S = '{' + SVG + '}'
FILES = {'quick':'быстрые настройки.svg', 'calendar':'календарь.svg',
         'sber':'sber меню.svg', 'wifi':'wifi.svg', 'bluetooth':'bluetooth.svg',
         'launcher':'меню приложений.svg', 'search':'поиск.svg',
         'notifications':'меню уведомлений.svg'}
APP_IDS = ['browser','usersoft','jazz','pulse','pixso','varm','online','mail',
           'python','emp','office','chat','friend','pdf','boards','f1',
           'citrix','sigma','disk','docs','access','potok','protocol','vpn',
           'mapp','isy','space','shares','design','boost','aigen','files']
cache = {}
manifest = {'sources':{}, 'geometry':{}, 'icons':[], 'apps':APP_IDS,
            'note':'Vector paths preserved. Embedded images: PNG icons and JPEG wallpaper <=1920px, icon art <=240px. Text is outlined; no font-family information in the exports.'}
for folder in ['references','apps','icons']:
    (OUTPUT/folder).mkdir(parents=True,exist_ok=True)

def compact_image(data):
    digest=hashlib.sha256(data).hexdigest()
    if digest not in cache:
        im=Image.open(io.BytesIO(data))
        wallpaper=im.width==4096 and im.height==2304
        im.thumbnail((1920,1080) if wallpaper else (240,240),Image.Resampling.LANCZOS)
        out=io.BytesIO()

        if wallpaper: im.convert('RGB').save(out,format='JPEG',quality=95,optimize=True)
        else: im.save(out,format='PNG',optimize=True)
        cache[digest]=out.getvalue()
    return cache[digest]

def load(key):
    data=(SOURCE/FILES[key]).read_bytes()
    root=ET.fromstring(data)
    manifest['sources'][key]={'file':FILES[key],'sha256':hashlib.sha256(data).hexdigest(),'viewBox':root.get('viewBox')}
    for image in root.iter(S+'image'):
        href=image.get('{'+XLINK+'}href','')
        if not href.startswith('data:'):raise ValueError('Unexpected external SVG image')
        encoded=compact_image(base64.b64decode(href.split(',',1)[1]))
        mime='image/jpeg' if encoded.startswith(b'\xff\xd8') else 'image/png'
        image.set('{'+XLINK+'}href','data:'+mime+';base64,'+base64.b64encode(encoded).decode())
        if float(image.get('width','0'))==4096:
            Image.open(io.BytesIO(encoded)).save(OUTPUT/'wallpaper.webp',format='WEBP',quality=95,method=6)
    return root

def rect_box(e):
    rect=e.find(S+'rect')
    if rect is None:return None
    return [float(rect.get(k,'0')) for k in ['x','y','width','height']]

def named(root,id):
    return next(e for e in root.iter(S+'g') if e.get('id')==id)

def at(root,x,y,w,id='icon'):
    for e in root.iter(S+'g'):
        box=rect_box(e)
        if e.get('id')==id and box and all(abs(a-b)<.01 for a,b in zip(box,[x,y,w,w])):return e
    raise ValueError(f'No frame {id} at {x},{y},{w}')

def export(root,body,box,path,mirror=False):
    # Referenced definitions can include top-level masks as well as <defs> nodes.
    ids={e.get('id'):e for e in root.iter() if e.get('id')}
    doc=ET.Element(S+'svg',{'viewBox':' '.join(f'{n:g}' for n in box),'width':f'{box[2]:g}','height':f'{box[3]:g}','fill':'none'})
    definitions=ET.SubElement(doc,S+'defs')
    copied=copy.deepcopy(body)
    pending=[copied];seen=set()
    while pending:
        node=pending.pop()
        for e in node.iter():
            for key,value in e.attrib.items():
                refs=re.findall(r'url\(#([^)]*)\)',value)
                if key.endswith('href') and value.startswith('#'):refs.append(value[1:])
                for ref in refs:
                    if ref not in seen and ref in ids:
                        seen.add(ref);dep=copy.deepcopy(ids[ref]);definitions.append(dep);pending.append(dep)
    if mirror:
        wrapper=ET.SubElement(doc,S+'g',{'transform':f'translate({box[0]*2+box[2]:g} 0) scale(-1 1)'})
        wrapper.append(copied)
    else:doc.append(copied)
    ET.ElementTree(doc).write(path,encoding='utf-8',xml_declaration=True)

def geometry(root):
    items=[]
    for e in root.iter(S+'g'):
        box=rect_box(e)
        if e.get('id') and box and (box[2]>=300 and box[3]>=70 or e.get('id') in ['sound','display','volume.line','display.line','launchpad.apps']):
            rect=e.find(S+'rect')
            items.append({'id':e.get('id'),'box':box,'fill':rect.get('fill'),'opacity':rect.get('fill-opacity'),'radius':rect.get('rx')})
    return items

roots={}
for key in FILES:
    root=load(key)
    manifest['geometry'][key]=geometry(root)
    ET.ElementTree(root).write(OUTPUT/'references'/f'{key}.svg',encoding='utf-8',xml_declaration=True)
    # Keep only the roots reused below in memory.
    if key in ['quick','sber','launcher','search']:roots[key]=root
    print(key,'optimized')

quick=roots['quick'];sber=roots['sber'];launcher=roots['launcher'];search=roots['search']
export(quick,named(quick,'labels.workplace'),[0,0,1920,1080],OUTPUT/'desktop.svg')
export(quick,named(quick,'launchpad'),[112,1016,40,40],OUTPUT/'launchpad.svg')
# The avatar frame contains the dedicated image and its original circular mask.
avatar=ET.Element(S+'g')
for e in quick.iter(S+'rect'):
    if e.get('id')=='IMG_7393' and float(e.get('y','0'))>=1016:
        avatar.append(copy.deepcopy(e))
if not len(avatar):raise ValueError('Avatar art absent')
export(quick,avatar,[748,1016,40,40],OUTPUT/'avatar.svg')

apps=named(launcher,'launchpad.apps');frames=[]
for line in apps.findall(S+'g'):
    frames.extend(g for g in line.findall(S+'g') if rect_box(g) and abs(rect_box(g)[2]-120)<.01)
assert len(frames)==32
for app,frame in zip(APP_IDS,frames):
    box=rect_box(frame);art=copy.deepcopy(frame)
    for child in list(art):
        if child.tag==S+'path' and not child.get('id'):art.remove(child) # outlined label, kept as editable HTML text
    export(launcher,art,[box[0],box[1],120,120],OUTPUT/'apps'/f'{app}.svg')

icons={
 'sber':(quick,at(quick,40,1024,24),[40,1024,24,24]),
 'settings':(sber,at(sber,40,880,24),[40,880,24,24]),
 'terminal':(sber,at(sber,40,928,24),[40,928,24,24]),
 'power':(sber,at(sber,40,976,24),[40,976,24,24]),
 'down':(sber,at(sber,40,1024,24),[40,1024,24,24]),
 'right':(quick,at(quick,1628,744,16,'chevron-right'),[1628,744,16,16]),
 'controls':(quick,named(quick,'toggles'),[1692,1024,24,24]),
 'wifi':(quick,at(quick,1452,744,16),[1452,744,16,16]),
 'bluetooth':(quick,named(quick,'bluetooth'),[1452,808,16,16]),
 'battery':(quick,named(quick,'icon.battery'),[1448,484,24,24]),
 'speaker':(quick,at(quick,1440,584,24),[1440,584,24,24]),
 'sun':(quick,at(quick,1440,668,24),[1440,668,24,24]),
 'moon':(quick,named(quick,'moon'),[1684,936,16,16]),
 'plane':(quick,named(quick,'plane'),[1452,936,16,16]),
 'night':(quick,named(quick,'sunrise'),[1684,872,16,16]),
 'bellOff':(quick,named(quick,'bell-off'),[1452,872,16,16]),
 'capture':(quick,named(quick,'.screen'),[1848,484,24,24]),
}
for key,id in [('filePdf','file-pdf-filled'),('fileWord','file-word-filled'),('filePowerpoint','file-power point-filled'),('fileImage','file-image-filled'),('fileExcel','file-excel-filled'),('file','file')]:
    try:
        g=named(search,id);box=rect_box(g)
        if box:icons[key]=(search,g,box)
    except StopIteration:pass
for name,(root,node,box) in icons.items():
    export(root,node,box,OUTPUT/'icons'/f'{name}.svg')
export(quick,icons['right'][1],icons['right'][2],OUTPUT/'icons/left.svg',mirror=True)
manifest['icons']=sorted([*icons,'left'])
# Inline mask data keeps local file: previews independent of mask image CORS.
mask_names=[name for name in manifest['icons'] if not name.startswith('file')]
mask_rules=[]
for name in mask_names:
    data=base64.b64encode((OUTPUT/'icons'/f'{name}.svg').read_bytes()).decode()
    url='url("data:image/svg+xml;base64,'+data+'")'
    mask_rules.append(f'.original-icon[data-glyph="{name}"] {{ mask-image: {url}; -webkit-mask-image: {url}; }}')
(OUTPUT/'icons.css').write_text('/* Extracted source geometry. Generated by tools/extract-svg-assets.py. */\n'+'\n'.join(mask_rules)+'\n')
(OUTPUT/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
print('Extracted',len(frames),'app icons,',len(manifest['icons']),'system icons')
