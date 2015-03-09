Creating a MenuOption object, saving it, and getting it's objectId

    MenuOption *testMenuOption = [MenuOption object];
    NSLog(@"objectId: %@", testMenuOption.objectId);
    testMenuOption.name = @"test-name";
    testMenuOption.price = @(99);
    testMenuOption.description = @"This is a test menu option for parse subclassing";
    testMenuOption.imageUrl = @"http://static1.squarespace.com/static/54b5bb0de4b0a14bf3e854e0/54b6d4f5e4b0b6737de70fb4/54c26580e4b0b23209566020/1422026122085/Pasta+Salad+Front.jpg";
    [testMenuOption save];
    NSLog(@"objectId: %@", testMenuOption.objectId);
    
