# JCDCoreData

Everything you need to set up a Core Data stack on top of an SQLite persistent store and begin interacting with it. Just add data model.

## Configuration

Out of the box JCDCoreData assumes your data model is named after your app. It also assumes your models' entity names match their class names.

## Getting Started

1. Create a new project (make sure 'Use Core Data' is not checked) and drag JCDCoreData.h/m into the source list
2. Add the CoreData framework to your new project
3. Add a data model to your project and name it exactly like your app name ("MyApp" = "MyApp.xcodemodeld")
4. Add some entities
5. Select your entities and click "Editor", then "Create NSManagedObject Subclass..." (or use MOGenerator)

## Usage

    // Get a managed object context
    NSManagedObjectContext *context = [JCDCoreData defaultContext];
    
    // Add a new entity
    MyEntity *entity = [MyEntity newObjectInContext:context];
    
    // Fetch existing entities
    NSArray *entities = [MyEntity fetchAllInContext:context];
  
See JCDCoreData.h for all available helper methods.
  
