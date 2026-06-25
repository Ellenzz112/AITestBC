// query 50101 "Sales Order Lines Query"
// {
//     ApplicationArea = All;
//     Caption = 'Sales Order Lines';
//     QueryType = Normal;

//     dataitem(SalesHeader; "Sales Header")
//     {
//         // Only Sales Orders
//         DataItemTableView = SORTING(No) WHERE("Document Type" = CONST(Order));

//         column(OrderNo; "No.")
//         {
//             Caption = 'Order No.';
//         }

//         column(CustomerNo; "Sell-to Customer No.")
//         {
//             Caption = 'Customer No.';
//         }

//         dataitem(SalesLine; "Sales Line")
//         {
//             // Link lines to header (Document No. on Sales Line = No. on Sales Header)
//             DataItemLink = "Document No." = field("No."), "Document Type" = field("Document Type");

//             column(ItemNo; "No.")
//             {
//                 Caption = 'Item No.';
//             }

//             column(LineAmount; "Line Amount")
//             {
//                 Caption = 'Line Amount';
//             }
//         }
//     }
// }