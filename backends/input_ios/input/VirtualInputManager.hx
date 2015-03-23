package input;

@:access(input.VirtualInput)
class VirtualInputManager
{
	private static var keyboardInstance: VirtualInputManager;

	private var mainKeyboard: VirtualInput;

	private function new()
	{
		mainKeyboard = new VirtualInput();
	}

	public static inline function instance(): VirtualInputManager
	{
		return keyboardInstance;
	}

    public function getVirtualKeyboard(): VirtualInput
    {
		return mainKeyboard;
	}

    public static function initialize(finishedCallback: Void -> Void): Void
    {
        keyboardInstance = new VirtualInputManager();

        // TODO callback

        if (finishedCallback != null)
        {
            finishedCallback();
        }
    }

    public static function show(): Void
    {
        // TODO show
    }

    public static function hide(): Void
    {
        // TODO hide
    }
}
