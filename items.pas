(* Items and objects in the game world *)

unit items;

{$mode objfpc}{$H+}

interface

uses
  globalutils, map, universe, item_lookup;

type
  (* Item types = drink, weapon, armour, missile *)

  (* Store information about items *)
  Item = record
    (* Unique ID *)
    itemID: smallint;
    (* Item name & description *)
    itemName, itemDescription: shortstring;
    (* drink, weapon, armour, missile *)
    itemType: shortstring;
    (* Used for lookup table *)
    useID: smallint;
    (* Position on game map *)
    posX, posY: smallint;
    (* Character used to represent item on game map *)
    glyph: shortstring;
    (* Colour of the glyph *)
    glyphColour: shortstring;
    (* Is the item in the players FoV *)
    inView: boolean;
    (* Is the item on the map *)
    onMap: boolean;
    (* Displays a message the first time item is seen *)
    discovered: boolean;
  end;

var
  itemList: array of Item;
  itemAmount, listLength: smallint;

(* Generate list of items on the map *)
procedure initialiseItems;
(* Update the map display to show all items *)
procedure drawItemsOnMap(id: byte);
(* Is there an item at coordinates *)
function containsItem(x, y: smallint): boolean;
(* Get name of item at coordinates *)
function getItemName(x, y: smallint): shortstring;
(* Get description of item at coordinates *)
function getItemDescription(x, y: smallint): shortstring;
(* Redraw all items *)
procedure redrawItems;

implementation

procedure initialiseItems;
var
  i: byte;
begin
  itemAmount := 0;
  { initialise array }
  SetLength(itemList, 0);
//  for i := 1 to 50 do
    item_lookup.dispenseItem;
end;

procedure drawItemsOnMap(id: byte);
begin
  (* Redraw all items on the map display *)
  if (itemList[id].inView = True) then
  begin
  map.mapDisplay[itemList[id].posY, itemList[id].posX].glyphColour :=
    itemList[id].glyphColour;
  map.mapDisplay[itemList[id].posY, itemList[id].posX].glyph :=
    itemList[id].glyph;
  end;
end;

function containsItem(x, y: smallint): boolean;
var
  i: smallint;
begin
  Result := False;
  for i := 1 to itemAmount do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
      Result := True;
  end;
end;

function getItemName(x, y: smallint): shortstring;
var
  i: smallint;
begin
  for i := 1 to itemAmount do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
      Result := itemList[i].itemName;
  end;
end;

function getItemDescription(x, y: smallint): shortstring;
var
  i: smallint;
begin
  for i := 1 to itemAmount do
  begin
    if (itemList[i].posX = x) and (itemList[i].posY = y) then
      Result := itemList[i].itemDescription;
  end;
end;

procedure redrawItems;
begin

end;

end.
