package input;

import msignal.Signal;

class VirtualInput
{
    public var onInputStarted(default, null): Signal0;
    public var onInputEnded(default, null): Signal0;
    public var onTextChanged(default, null): Signal1<String>;

    public var string(default, set): String;

    public function new()
    {
        onInputStarted = new Signal0();
        onInputEnded = new Signal0();
        onTextChanged = new Signal1();

        string = "";
    }

    private function set_string(value: String): String
    {
        // TODO
        return string = value;
    }
}