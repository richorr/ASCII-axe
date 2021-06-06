(* Unit responsible for saving and loading data *)

unit file_handling;

{$mode objfpc}{$H+}
{$modeswitch UnicodeStrings}

interface

uses
  SysUtils, DOM, XMLWrite, XMLRead, TypInfo, globalutils, universe,
  cave, items, entities, player_inventory;

(* Write a newly generate level of a dungeon to disk *)
procedure writeNewDungeonLevel(idNumber, lvlNum, totalDepth, totalRooms: byte;
  dtype: dungeonTerrain);
(* Write explored dungeon level to disk *)
procedure saveDungeonLevel;
(* Read dungeon level from disk *)
procedure loadDungeonLevel(lvl: byte);
(* Delete saved game files *)
procedure deleteGameData;
(* Load a saved game *)
procedure loadGame;
(* Save game state to file *)
procedure saveGame;

implementation

uses
  map;

procedure writeNewDungeonLevel(idNumber, lvlNum, totalDepth, totalRooms: byte;
  dtype: dungeonTerrain);

var
  r, c, id_int: smallint;
  Doc: TXMLDocument;
  RootNode, dataNode: TDOMNode;
  dfileName, Value: string;

  procedure AddElement(Node: TDOMNode; Name, Value: string);
  var
    NameNode, ValueNode: TDomNode;
  begin
    { creates future Node/Name }
    NameNode := Doc.CreateElement(Name);
    { creates future Node/Name/Value }
    ValueNode := Doc.CreateTextNode(Value);
    { place value in place }
    NameNode.Appendchild(ValueNode);
    { place Name in place }
    Node.Appendchild(NameNode);
  end;

  function AddChild(Node: TDOMNode; ChildName: string): TDomNode;

  var
    ChildNode: TDomNode;
  begin
    ChildNode := Doc.CreateElement(ChildName);
    Node.AppendChild(ChildNode);
    Result := ChildNode;
  end;

begin
  id_int := 0;
  dfileName := globalUtils.saveDirectory + PathDelim + 'd_' +
    IntToStr(idNumber) + '_f' + IntToStr(lvlNum) + '.dat';
  try
    { Create a document }
    Doc := TXMLDocument.Create;
    { Create a root node }
    RootNode := Doc.CreateElement('root');
    Doc.Appendchild(RootNode);
    RootNode := Doc.DocumentElement;

    (* Level data *)
    DataNode := AddChild(RootNode, 'levelData');
    AddElement(datanode, 'dungeonID', IntToStr(idNumber));
    AddElement(datanode, 'title', universe.title);
    AddElement(datanode, 'floor', IntToStr(lvlNum));
    AddElement(datanode, 'levelVisited', BoolToStr(False));
    AddElement(datanode, 'itemsOnThisFloor', IntToStr(0));
    AddElement(datanode, 'totalDepth', IntToStr(totalDepth));
    WriteStr(Value, dungeonType);
    AddElement(datanode, 'mapType', Value);
    AddElement(datanode, 'totalRooms', IntToStr(totalRooms));

    (* map tiles *)
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        Inc(id_int);
        DataNode := AddChild(RootNode, 'map_tiles');
        TDOMElement(dataNode).SetAttribute('id', IntToStr(id_int));
        { if dungeon type is a cave }
        if (dType = tCave) then
        begin
          if (cave.terrainArray[r][c] = '*') then
            AddElement(datanode, 'Blocks', BoolToStr(True))
          else
            AddElement(datanode, 'Blocks', BoolToStr(False));
        end;
        AddElement(datanode, 'Visible', BoolToStr(False));
        AddElement(datanode, 'Occupied', BoolToStr(False));
        AddElement(datanode, 'Discovered', BoolToStr(False));
        { if dungeon type is a cave }
        if (dType = tCave) then
        begin
          AddElement(datanode, 'Glyph', cave.terrainArray[r][c]);
        end;
      end;
    end;

    (* Save XML as a .dat file *)
    WriteXMLFile(Doc, dfileName);
  finally
    { free memory }
    Doc.Free;
  end;
end;

procedure saveDungeonLevel;
var
  r, c, id_int: smallint;
  Doc: TXMLDocument;
  RootNode, dataNode: TDOMNode;
  dfileName, Value: string;

  procedure AddElement(Node: TDOMNode; Name, Value: string);

  var
    NameNode, ValueNode: TDomNode;
  begin
    { creates future Node/Name }
    NameNode := Doc.CreateElement(Name);
    { creates future Node/Name/Value }
    ValueNode := Doc.CreateTextNode(Value);
    { place value in place }
    NameNode.Appendchild(ValueNode);
    { place Name in place }
    Node.Appendchild(NameNode);
  end;

  function AddChild(Node: TDOMNode; ChildName: string): TDomNode;
  var
    ChildNode: TDomNode;
  begin
    ChildNode := Doc.CreateElement(ChildName);
    Node.AppendChild(ChildNode);
    Result := ChildNode;
  end;

begin
  id_int := 0;
  dfileName := (globalUtils.saveDirectory + PathDelim + 'd_' +
    IntToStr(uniqueID) + '_f' + IntToStr(currentDepth) + '.dat');
  try
    { Create a document }
    Doc := TXMLDocument.Create;
    { Create a root node }
    RootNode := Doc.CreateElement('root');
    Doc.Appendchild(RootNode);
    RootNode := Doc.DocumentElement;

    (* Level data *)
    DataNode := AddChild(RootNode, 'levelData');
    AddElement(datanode, 'dungeonID', IntToStr(uniqueID));
    AddElement(datanode, 'title', universe.title);
    AddElement(datanode, 'floor', IntToStr(currentDepth));
    AddElement(datanode, 'levelVisited', BoolToStr(True));
    AddElement(datanode, 'itemsOnThisFloor', IntToStr(items.countNonEmptyItems));
    AddElement(datanode, 'totalDepth', IntToStr(totalDepth));
    WriteStr(Value, dungeonType);
    AddElement(datanode, 'mapType', Value);
    AddElement(datanode, 'totalRooms', IntToStr(totalRooms));

    (* map tiles *)
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        Inc(id_int);
        DataNode := AddChild(RootNode, 'map_tiles');
        TDOMElement(dataNode).SetAttribute('id', IntToStr(maparea[r][c].id));
        AddElement(datanode, 'Blocks', BoolToStr(map.maparea[r][c].Blocks));
        AddElement(datanode, 'Visible', BoolToStr(map.maparea[r][c].Visible));
        AddElement(datanode, 'Occupied', BoolToStr(map.maparea[r][c].Occupied));
        AddElement(datanode, 'Discovered', BoolToStr(map.maparea[r][c].Discovered));
        AddElement(datanode, 'Glyph', map.maparea[r][c].Glyph);
      end;
    end;

    (* Items on the map *)
    for i := 1 to items.itemAmount do
      (* Don't save empty items *)
      if (items.itemList[i].itemType <> itmEmptySlot) then
      begin
        begin
          DataNode := AddChild(RootNode, 'Items');
          TDOMElement(dataNode).SetAttribute('itemID', IntToStr(itemList[i].itemID));
          AddElement(DataNode, 'Name', itemList[i].itemName);
          AddElement(DataNode, 'description', itemList[i].itemDescription);
          WriteStr(Value, itemList[i].itemType);
          AddElement(DataNode, 'itemType', Value);
          WriteStr(Value, itemList[i].itemMaterial);
          AddElement(DataNode, 'itemMaterial', Value);
          AddElement(DataNode, 'useID', IntToStr(itemList[i].useID));
          { Convert extended ASCII to plain text }
          if (itemList[i].glyph = chr(24)) then
            AddElement(DataNode, 'glyph', '|')
          else
            AddElement(DataNode, 'glyph', itemList[i].glyph);
          AddElement(DataNode, 'glyphColour', itemList[i].glyphColour);
          AddElement(DataNode, 'inView', BoolToStr(itemList[i].inView));
          AddElement(DataNode, 'posX', IntToStr(itemList[i].posX));
          AddElement(DataNode, 'posY', IntToStr(itemList[i].posY));
          AddElement(DataNode, 'onMap', BoolToStr(itemList[i].onMap));
          AddElement(DataNode, 'discovered', BoolToStr(itemList[i].discovered));
        end;
      end;

    (* Save XML *)
    WriteXMLFile(Doc, dfileName);
  finally
    { free memory }
    Doc.Free;
  end;
end;

procedure loadDungeonLevel(lvl: byte);
var
  dfileName: string;
  RootNode, Tile, ItemsNode, ParentNode, NextNode, Blocks, Visible,
  Occupied, Discovered, GlyphNode: TDOMNode;
  Doc: TXMLDocument;
  r, c: integer;
  levelVisited: boolean;
begin
  dfileName := globalUtils.saveDirectory + PathDelim + 'd_' +
    IntToStr(uniqueID) + '_f' + IntToStr(lvl) + '.dat';
  try
    (* Read in dat file from disk *)
    ReadXMLFile(Doc, dfileName);
    (* Retrieve the nodes *)
    RootNode := Doc.DocumentElement.FindNode('levelData');
    (* Name of dungeon *)
    title := RootNode.FindNode('title').TextContent;
    (* Has this level been explored already *)
    levelVisited := StrToBool(RootNode.FindNode('levelVisited').TextContent);
    (* Number of items on current level *)
    items.itemAmount := StrToInt(RootNode.FindNode('itemsOnThisFloor').TextContent);
    (* Number of rooms in current level *)
    universe.totalRooms := StrToInt(RootNode.FindNode('totalRooms').TextContent);

    (* Map tile data *)
    Tile := RootNode.NextSibling;
    for r := 1 to MAXROWS do
    begin
      for c := 1 to MAXCOLUMNS do
      begin
        map.maparea[r][c].id := StrToInt(Tile.Attributes.Item[0].NodeValue);
        Blocks := Tile.FirstChild;
        map.maparea[r][c].Blocks := StrToBool(Blocks.TextContent);
        Visible := Blocks.NextSibling;
        map.maparea[r][c].Visible := StrToBool(Visible.TextContent);
        Occupied := Visible.NextSibling;
        map.maparea[r][c].Occupied := StrToBool(Occupied.TextContent);
        Discovered := Occupied.NextSibling;
        map.maparea[r][c].Discovered := StrToBool(Discovered.TextContent);
        GlyphNode := Discovered.NextSibling;
        (* Convert String to Char *)
        map.maparea[r][c].Glyph := GlyphNode.TextContent[1];
        NextNode := Tile.NextSibling;
        Tile := NextNode;
      end;
    end;

    (* Load items on this level if already visited *)
    if (levelVisited = True) then
    begin
      (* Items on the map *)
      SetLength(items.itemList, 1);
      ItemsNode := Doc.DocumentElement.FindNode('Items');
      for i := 1 to items.itemAmount do
      begin
        items.listLength := length(items.itemList);
        SetLength(items.itemList, items.listLength + 1);
        items.itemList[i].itemID := StrToInt(ItemsNode.Attributes.Item[0].NodeValue);
        items.itemList[i].itemName := ItemsNode.FindNode('Name').TextContent;
        items.itemList[i].itemDescription :=
          ItemsNode.FindNode('description').TextContent;
        items.itemList[i].itemType :=
          tItem(GetEnumValue(Typeinfo(tItem),
          ItemsNode.FindNode('itemType').TextContent));
        items.itemList[i].itemMaterial :=
          tMaterial(GetEnumValue(Typeinfo(tMaterial),
          ItemsNode.FindNode('itemMaterial').TextContent));
        items.itemList[i].useID := StrToInt(ItemsNode.FindNode('useID').TextContent);

        { Convert plain text to extended ASCII }
        if (ItemsNode.FindNode('glyph').TextContent[1] = '|') then
          items.itemList[i].glyph := chr(24)
        else
          items.itemList[i].glyph :=
            char(widechar(ItemsNode.FindNode('glyph').TextContent[1]));

        items.itemList[i].glyphColour :=
          ItemsNode.FindNode('glyphColour').TextContent;
        items.itemList[i].inView := StrToBool(ItemsNode.FindNode('inView').TextContent);
        items.itemList[i].posX := StrToInt(ItemsNode.FindNode('posX').TextContent);
        items.itemList[i].posY := StrToInt(ItemsNode.FindNode('posY').TextContent);
        items.itemList[i].onMap := StrToBool(ItemsNode.FindNode('onMap').TextContent);
        items.itemList[i].discovered :=
          StrToBool(ItemsNode.FindNode('discovered').TextContent);
        ParentNode := ItemsNode.NextSibling;
        ItemsNode := ParentNode;
      end;
    end
    else
      (* Generate new items if floor not already visited *)
      universe.litterItems;
    currentDepth := lvl;
  finally
    (* free memory *)
    Doc.Free;
  end;
end;

procedure deleteGameData;
var
  dfileName: string;
begin
  (* Set the save game file name *)
  dfileName := (globalUtils.saveDirectory + PathDelim + globalutils.saveFile);
  if (FileExists(dfileName)) then
    DeleteFile(dfileName);
end;

procedure loadGame;
var
  RootNode, ParentNode, InventoryNode, PlayerDataNode: TDOMNode;
  Doc: TXMLDocument;
  i: integer;
  dfileName: string;

begin
  try
    (* Set the save game file name *)
    dfileName := (globalUtils.saveDirectory + PathDelim + globalutils.saveFile);
    (* Read xml file from disk *)
    ReadXMLFile(Doc, dfileName);
    (* Retrieve the nodes *)
    RootNode := Doc.DocumentElement.FindNode('GameData');
    ParentNode := RootNode.FirstChild.NextSibling;
    (* Random seed *)
    RandSeed := StrToDWord(RootNode.FindNode('RandSeed').TextContent);
    (* Current dungeon ID *)
    universe.uniqueID := StrToInt(RootNode.FindNode('dungeonID').TextContent);
    (* Current depth *)
    universe.currentDepth := StrToInt(RootNode.FindNode('currentDepth').TextContent);

    (* Player data *)
    SetLength(entities.entityList, 0);
    PlayerDataNode := Doc.DocumentElement.FindNode('PlayerData');
    entities.listLength := length(entities.entityList);
    SetLength(entities.entityList, entities.listLength + 1);
    entities.entityList[0].npcID := 0;
    entities.entityList[0].race := PlayerDataNode.FindNode('race').TextContent;
    entities.entityList[0].description :=
      PlayerDataNode.FindNode('description').TextContent;
    entities.entityList[0].glyph :=
      char(widechar(PlayerDataNode.FindNode('glyph').TextContent[1]));
    entities.entityList[0].glyphColour :=
      PlayerDataNode.FindNode('glyphColour').TextContent;
    entities.entityList[0].maxHP :=
      StrToInt(PlayerDataNode.FindNode('maxHP').TextContent);
    entities.entityList[0].currentHP :=
      StrToInt(PlayerDataNode.FindNode('currentHP').TextContent);
    entities.entityList[0].attack :=
      StrToInt(PlayerDataNode.FindNode('attack').TextContent);
    entities.entityList[0].defence :=
      StrToInt(PlayerDataNode.FindNode('defence').TextContent);
    entities.entityList[0].weaponDice :=
      StrToInt(PlayerDataNode.FindNode('weaponDice').TextContent);
    entities.entityList[0].weaponAdds :=
      StrToInt(PlayerDataNode.FindNode('weaponAdds').TextContent);
    entities.entityList[0].xpReward :=
      StrToInt(PlayerDataNode.FindNode('xpReward').TextContent);
    entities.entityList[0].visionRange :=
      StrToInt(PlayerDataNode.FindNode('visRange').TextContent);
    entities.entityList[0].moveCount :=
      StrToInt(PlayerDataNode.FindNode('moveCount').TextContent);
    entities.entityList[0].targetX :=
      StrToInt(PlayerDataNode.FindNode('targetX').TextContent);
    entities.entityList[0].targetY :=
      StrToInt(PlayerDataNode.FindNode('targetY').TextContent);
    entities.entityList[0].inView := True;
    entities.entityList[0].blocks := False;
    entities.entityList[0].discovered := True;
    entities.entityList[0].weaponEquipped :=
      StrToBool(PlayerDataNode.FindNode('weaponEquipped').TextContent);
    entities.entityList[0].armourEquipped :=
      StrToBool(PlayerDataNode.FindNode('armourEquipped').TextContent);
    entities.entityList[0].isDead := False;
    entities.entityList[0].stsDrunk :=
      StrToBool(PlayerDataNode.FindNode('stsDrunk').TextContent);
    entities.entityList[0].stsPoison :=
      StrToBool(PlayerDataNode.FindNode('stsPoison').TextContent);
    entities.entityList[0].tmrDrunk :=
      StrToInt(PlayerDataNode.FindNode('tmrDrunk').TextContent);
    entities.entityList[0].tmrPoison :=
      StrToInt(PlayerDataNode.FindNode('tmrPoison').TextContent);
    entities.entityList[0].posX :=
      StrToInt(PlayerDataNode.FindNode('posX').TextContent);
    entities.entityList[0].posY :=
      StrToInt(PlayerDataNode.FindNode('posY').TextContent);

    (* Player Inventory *)
    player_inventory.initialiseInventory;

    InventoryNode := Doc.DocumentElement.FindNode('playerInventory');
    for i := 0 to 9 do
    begin
      player_inventory.inventory[i].id := i;
      player_inventory.inventory[i].Name :=
        InventoryNode.FindNode('Name').TextContent;
      player_inventory.inventory[i].equipped :=
        StrToBool(InventoryNode.FindNode('equipped').TextContent);
      player_inventory.inventory[i].description :=
        InventoryNode.FindNode('description').TextContent;
      player_inventory.inventory[i].itemType :=
        tItem(GetEnumValue(Typeinfo(tItem), InventoryNode.FindNode(
        'itemType').TextContent));
      player_inventory.inventory[i].itemMaterial :=
        tMaterial(GetEnumValue(Typeinfo(tMaterial),
        InventoryNode.FindNode('itemMaterial').TextContent));
      player_inventory.inventory[i].useID :=
        StrToInt(InventoryNode.FindNode('useID').TextContent);

      { Convert plain text to extended ASCII }
      if (InventoryNode.FindNode('glyph').TextContent[1] = '|') then
        player_inventory.inventory[i].glyph := chr(24)
      else
        player_inventory.inventory[i].glyph :=
          char(widechar(InventoryNode.FindNode('glyph').TextContent[1]));

      player_inventory.inventory[i].glyphColour :=
        InventoryNode.FindNode('glyphColour').TextContent;
      player_inventory.inventory[i].inInventory :=
        StrToBool(InventoryNode.FindNode('inInventory').TextContent);
      ParentNode := InventoryNode.NextSibling;
      InventoryNode := ParentNode;
    end;
  finally
    (* free memory *)
    Doc.Free;
  end;
end;

procedure saveGame;
var
  Doc: TXMLDocument;
  RootNode, dataNode: TDOMNode;
  dfileName, Value: string;

  procedure AddElement(Node: TDOMNode; Name, Value: string);
  var
    NameNode, ValueNode: TDomNode;
  begin
    { creates future Node/Name }
    NameNode := Doc.CreateElement(Name);
    { creates future Node/Name/Value }
    ValueNode := Doc.CreateTextNode(Value);
    { place value in place }
    NameNode.Appendchild(ValueNode);
    { place Name in place }
    Node.Appendchild(NameNode);
  end;

  function AddChild(Node: TDOMNode; ChildName: string): TDomNode;
  var
    ChildNode: TDomNode;
  begin
    ChildNode := Doc.CreateElement(ChildName);
    Node.AppendChild(ChildNode);
    Result := ChildNode;
  end;

begin
  (* Set this floor to Visited *)
  levelVisited := True;
  (* First save the current level data *)
  saveDungeonLevel;
  (* Save game stats *)
  dfileName := (globalUtils.saveDirectory + PathDelim + globalutils.saveFile);
  try
    (* Create a document *)
    Doc := TXMLDocument.Create;
    (* Create a root node *)
    RootNode := Doc.CreateElement('root');
    Doc.Appendchild(RootNode);
    RootNode := Doc.DocumentElement;

    (* Game data *)
    DataNode := AddChild(RootNode, 'GameData');
    AddElement(datanode, 'RandSeed', IntToStr(RandSeed));
    AddElement(datanode, 'dungeonID', IntToStr(uniqueID));
    AddElement(datanode, 'currentDepth', IntToStr(currentDepth));
    AddElement(datanode, 'levelVisited', BoolToStr(True));
    AddElement(datanode, 'itemsOnThisFloor', IntToStr(items.itemAmount));
    AddElement(datanode, 'totalDepth', IntToStr(totalDepth));
    WriteStr(Value, dungeonType);
    AddElement(datanode, 'mapType', Value);
    AddElement(datanode, 'npcAmount', IntToStr(entities.npcAmount));
    AddElement(datanode, 'itemAmount', IntToStr(items.itemAmount));

    (* Player data *)
    DataNode := AddChild(RootNode, 'PlayerData');
    AddElement(DataNode, 'race', entities.entityList[0].race);
    AddElement(DataNode, 'description', entities.entityList[0].description);
    AddElement(DataNode, 'glyph', entities.entityList[0].glyph);
    AddElement(DataNode, 'glyphColour', entities.entityList[0].glyphColour);
    AddElement(DataNode, 'maxHP', IntToStr(entities.entityList[0].maxHP));
    AddElement(DataNode, 'currentHP', IntToStr(entities.entityList[0].currentHP));
    AddElement(DataNode, 'attack', IntToStr(entities.entityList[0].attack));
    AddElement(DataNode, 'defence', IntToStr(entities.entityList[0].defence));
    AddElement(DataNode, 'weaponDice', IntToStr(entities.entityList[0].weaponDice));
    AddElement(DataNode, 'weaponAdds', IntToStr(entities.entityList[0].weaponAdds));
    AddElement(DataNode, 'xpReward', IntToStr(entities.entityList[0].xpReward));
    AddElement(DataNode, 'visRange', IntToStr(entities.entityList[0].visionRange));
    AddElement(DataNode, 'moveCount', IntToStr(entities.entityList[0].moveCount));
    AddElement(DataNode, 'targetX', IntToStr(entities.entityList[0].targetX));
    AddElement(DataNode, 'targetY', IntToStr(entities.entityList[0].targetY));
    AddElement(DataNode, 'weaponEquipped',
      BoolToStr(entities.entityList[0].weaponEquipped));
    AddElement(DataNode, 'armourEquipped',
      BoolToStr(entities.entityList[0].armourEquipped));
    AddElement(DataNode, 'stsDrunk', BoolToStr(entities.entityList[0].stsDrunk));
    AddElement(DataNode, 'stsPoison', BoolToStr(entities.entityList[0].stsPoison));
    AddElement(DataNode, 'tmrDrunk', IntToStr(entities.entityList[0].tmrDrunk));
    AddElement(DataNode, 'tmrPoison', IntToStr(entities.entityList[0].tmrPoison));
    AddElement(DataNode, 'posX', IntToStr(entities.entityList[0].posX));
    AddElement(DataNode, 'posY', IntToStr(entities.entityList[0].posY));

    (* Player inventory *)
    for i := 0 to 9 do
    begin
      DataNode := AddChild(RootNode, 'playerInventory');
      TDOMElement(dataNode).SetAttribute('id', IntToStr(i));
      AddElement(DataNode, 'Name', inventory[i].Name);
      AddElement(DataNode, 'equipped', BoolToStr(inventory[i].equipped));
      AddElement(DataNode, 'description', inventory[i].description);
      WriteStr(Value, inventory[i].itemType);
      AddElement(DataNode, 'itemType', Value);
      WriteStr(Value, inventory[i].itemMaterial);
      AddElement(DataNode, 'itemMaterial', Value);
      AddElement(DataNode, 'useID', IntToStr(inventory[i].useID));
      { Convert extended ASCII to plain text }
      if (inventory[i].glyph = chr(24)) then
        AddElement(DataNode, 'glyph', '|')
      else
        AddElement(DataNode, 'glyph', inventory[i].glyph);
      AddElement(DataNode, 'glyphColour', inventory[i].glyphColour);
      AddElement(DataNode, 'inInventory', BoolToStr(inventory[i].inInventory));
    end;

    { Plot elements }

    (* Save XML *)
    WriteXMLFile(Doc, dfileName);
  finally
    { Free memory }
    Doc.Free;
  end;
end;

end.
