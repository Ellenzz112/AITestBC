namespace AIAgent.AIAgent;
using Microsoft.Inventory.Transfer;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Ledger;

codeunit 50101 "Transfer Order Tests"
{
    Subtype = Test;

    [Test]
    procedure TestTransferShipmentCreatesItemLedgerEntry()
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
        Location: Record Location;
        TransferPostShipment: Codeunit "TransferOrder-Post Shipment";
        EntryCount: Integer;
    begin
        // Setup data

        Item.Get('1000');

        TransferHeader.Init();
        TransferHeader.Insert(true);
        TransferHeader.Validate("Transfer-from Code", 'BLUE');
        TransferHeader.Validate("Transfer-to Code", 'RED');
        TransferHeader.Modify(true);

        TransferLine.Init();
        TransferLine.Validate("Document No.", TransferHeader."No.");
        TransferLine.Validate("Item No.", Item."No.");
        TransferLine.Validate(Quantity, 1);
        TransferLine.Insert(true);

        // Post Shipment

        TransferPostShipment.Run(TransferHeader);

        // Verify

        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetRange("Item No.", Item."No.");

        EntryCount := ItemLedgerEntry.Count();

        if EntryCount = 0 then
            Error('Item Ledger Entry was not created.');
    end;
}
