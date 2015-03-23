package input;

import msignal.Signal;

extern class VirtualInput
{
    public var onInputStarted(default, null): Signal0;
    public var onInputEnded(default, null): Signal0;
    public var onTextChanged(default, null): Signal1<String>;

    public var string(default, set): String;
}