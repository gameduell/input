package input;

import input.util.CharSet;

@:access(input.VirtualInput)
class VirtualInputManager
{
    private static var keyboardInstance: VirtualInputManager;
    private var mainKeyboard: VirtualInput;

    private function new()
    {
        mainKeyboard = new VirtualInput(CharSet.englishCharCodeSet());
    }

    public static inline function instance(): VirtualInputManager
    {
        return keyboardInstance;
    }

    public static function initialize(finishedCallback: Void -> Void): Void
    {
        keyboardInstance = new VirtualInputManager();

        if (finishedCallback != null)
        {
            finishedCallback();
        }
    }

    public function getVirtualKeyboard(): VirtualInput
    {
        return mainKeyboard;
    }

    public function show(): Void
    {
        mainKeyboard.show();
    }

    public function hide(): Void
    {
        mainKeyboard.hide();
    }
}
