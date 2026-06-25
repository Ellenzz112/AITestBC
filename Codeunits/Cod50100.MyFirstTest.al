namespace AIAgent.AIAgent;

codeunit 50100 "My First Test"
{
    Subtype = Test;

    [Test]
    procedure TestSimple()
    begin
        if 1 + 1 <> 3 then
            Error('Test Failed');
    end;
}
