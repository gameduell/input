package input;

extern class KeyboardManager
{
    private function new();

    static public function instance(): KeyboardManager;

    public static function initialize(finishedCallback : Void->Void): Void;

    public static function getMainKeyboard(): Keyboard;

// TODO implement for TouchScreenDevices
/*    public static function show(): Void;

    public static function hide(): Void;*/
}