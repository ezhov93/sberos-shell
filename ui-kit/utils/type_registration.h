#pragma once

#include <QCoreApplication>
#include <QQmlEngine>

#define REGISTER(T, URI, MAJOR, MINOR, NAME)                                                       \
    template <> const char *const TypeRegistration::BaseType<T>::Uri = URI;                        \
    template <> const int TypeRegistration::BaseType<T>::Major = MAJOR;                            \
    template <> const int TypeRegistration::BaseType<T>::Minor = MINOR;                            \
    template <> const char *const TypeRegistration::BaseType<T>::Name = NAME;

#define REGISTER_TYPE(T, URI, MAJOR)                                                               \
    REGISTER(T, URI, MAJOR, 1, "")                                                                 \
    static TypeRegistration::Type<T> r_##T;

#define REGISTER_CREATABLE_TYPE(T, URI, MAJOR, MINOR, NAME)                                        \
    REGISTER(T, URI, MAJOR, MINOR, NAME)                                                           \
    static TypeRegistration::CreatableType<T> r_##T;

#define REGISTER_UNCREATABLE_TYPE(T, URI, MAJOR, MINOR, NAME)                                      \
    REGISTER(T, URI, MAJOR, MINOR, NAME)                                                           \
    static TypeRegistration::UncreatableType<T> r_##T;

#define REGISTER_SINGLETON_TYPE(T, URI, MAJOR, MINOR, NAME)                                        \
    REGISTER(T, URI, MAJOR, MINOR, NAME)                                                           \
    static TypeRegistration::SingletonType<T> r_##T;

#define REGISTER_SINGLETON_INSTANCE(T, URI, MAJOR, MINOR, NAME)                                    \
    REGISTER(T, URI, MAJOR, MINOR, NAME)                                                           \
    static TypeRegistration::SingletonInstance<T> r_##T;

#define REGISTER_SINGLETON_INITILIZABLE_INSTANCE(T, URI, MAJOR, MINOR, NAME, INIT_FUNC)            \
    REGISTER(T, URI, MAJOR, MINOR, NAME)                                                           \
    template <>                                                                                    \
    const std::function<void(QQmlEngine *, QJSEngine *)>                                           \
        TypeRegistration::SingletonInitilizableInstance<T>::InitFunc = INIT_FUNC;                  \
    static TypeRegistration::SingletonInitilizableInstance<T> r_##T;

#define REGISTER_JS_SINGLETON_TYPE(T, URI, MAJOR, MINOR, NAME)                                     \
    REGISTER(T, URI, MAJOR, MINOR, NAME)                                                           \
    static TypeRegistration::JSSingletonType<T> r_##T;

namespace TypeRegistration {
template <typename T> struct BaseType {
    static const char *const Uri;
    static const int Major;
    static const int Minor;
    static const char *const Name;
};

template <typename T> struct Type : public BaseType<T> {
    Type() {
        qAddPreRoutine(
            []() { qmlRegisterTypesAndRevisions<T>(BaseType<T>::Uri, BaseType<T>::Major); });
    }
};

template <typename T> struct CreatableType : public BaseType<T> {
    CreatableType() {
        qAddPreRoutine([]() {
            qmlRegisterType<T>(BaseType<T>::Uri, BaseType<T>::Major, BaseType<T>::Minor,
                               BaseType<T>::Name);
        });
    }
};

template <typename T> struct UncreatableType : public BaseType<T> {
    UncreatableType() {
        qAddPreRoutine([]() {
            qmlRegisterUncreatableType<T>(
                BaseType<T>::Uri, BaseType<T>::Major, BaseType<T>::Minor, BaseType<T>::Name,
                QStringLiteral("%1 is for C++ instantiation only").arg(UncreatableType<T>::Name));
        });
    }
};

template <typename T> struct SingletonType : public BaseType<T> {
    SingletonType() {
        qAddPreRoutine([]() {
            constexpr bool hasGet = requires(const T &t) { t.Get(); };
            if constexpr (hasGet) {
                static auto callback = [](QQmlEngine *engine,
                                          QJSEngine *scriptEngine) -> QObject * {
                    engine->setObjectOwnership(T::Get(), QQmlEngine::ObjectOwnership::CppOwnership);
                    return T::Get();
                };
                qmlRegisterSingletonType<T>(BaseType<T>::Uri, BaseType<T>::Major,
                                            BaseType<T>::Minor, BaseType<T>::Name, callback);
            } else {
                static auto callback = [](QQmlEngine *engine,
                                          QJSEngine *scriptEngine) -> QObject * {
                    auto obj = new T(engine);
                    engine->setObjectOwnership(obj,
                                               QQmlEngine::ObjectOwnership::JavaScriptOwnership);
                    return obj;
                };
                qmlRegisterSingletonType<T>(BaseType<T>::Uri, BaseType<T>::Major,
                                            BaseType<T>::Minor, BaseType<T>::Name, callback);
            }
        });
    }
};

template <typename T> struct SingletonInstance : public BaseType<T> {
    SingletonInstance() {
        qAddPreRoutine([]() {
            qmlRegisterSingletonInstance(BaseType<T>::Uri, BaseType<T>::Major, BaseType<T>::Minor,
                                         BaseType<T>::Name, T::Get());
        });
    }
};

template <typename T> struct SingletonInitilizableInstance : public BaseType<T> {
    SingletonInitilizableInstance() {
        qAddPreRoutine([]() {
            static auto init_callback = [](QQmlEngine *engine,
                                           QJSEngine *scriptEngine) -> QObject * {
                auto object = T::Get();
                SingletonInitilizableInstance::InitFunc(engine, scriptEngine);
                engine->setObjectOwnership(object, QQmlEngine::ObjectOwnership::CppOwnership);
                return object;
            };
            qmlRegisterSingletonType<T>(BaseType<T>::Uri, BaseType<T>::Major, BaseType<T>::Minor,
                                        BaseType<T>::Name, init_callback);
        });
    }

    static const std::function<void(QQmlEngine *, QJSEngine *)> InitFunc;
};

template <typename T> struct JSSingletonType : public BaseType<T> {
    JSSingletonType() {
        qAddPreRoutine([]() {
            static auto callback = [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject * {
                QObject *ptr = new T();
                engine->setObjectOwnership(ptr, QQmlEngine::ObjectOwnership::JavaScriptOwnership);
                return ptr;
            };
            qmlRegisterSingletonType<T>(BaseType<T>::Uri, BaseType<T>::Major, BaseType<T>::Minor,
                                        BaseType<T>::Name, callback);
        });
    }
};
} // namespace TypeRegistration
