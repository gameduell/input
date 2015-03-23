package input;

import hxjni.JNI;
import msignal.Signal;

class VirtualInput
{
    private static var initNative = JNI.createStaticMethod("org/haxe/duell/input/keyboard/TextField",
    "init", "(Lorg/haxe/duell/hxjni/HaxeObject;)Lorg/haxe/duell/input/keyboard/TextField;");
    private static var showNative = JNI.createMemberMethod("org/haxe/duell/input/keyboard/TextField", "show", "()V");
    private static var hideNative = JNI.createMemberMethod("org/haxe/duell/input/keyboard/TextField", "hide", "()V");
    private static var setStringNative = JNI.createMemberMethod("org/haxe/duell/input/keyboard/TextField",
    "setString", "(Ljava/lang/String;)V");

    private var javaObj: Dynamic;

    public var onInputStarted(default, null): Signal0;
    public var onInputEnded(default, null): Signal0;
    public var onTextChanged(default, null): Signal1<String>;

    public var string(default, set): String;

    private function new()
    {
        onInputStarted = new Signal0();
        onInputEnded = new Signal0();
        onTextChanged = new Signal1();

        javaObj = initNative(this);
        string = "";
    }

    private function show(): Void
    {
        showNative(javaObj);
    }

    private function hide(): Void
    {
        hideNative(javaObj);
    }

    public function onTextChangedCallback(data: Dynamic)
    {
        string = data;

        onTextChanged.dispatch(string);
    }

    public function onInputStartedCallback()
    {
        onInputStarted.dispatch();
    }

    public function onInputEndedCallback()
    {
        onInputEnded.dispatch();
    }

    public function set_string(value: String): String
    {
        setStringNative(javaObj, value);
        return string = value;
    }
}