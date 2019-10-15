# CoreDataMissingObjectsDemonstration
Demonstration of Core Data missing objects and relationships

## Checklist for the solution below
- You are getting `<x-coredata: UDID; data: fault>`, despite setting `fetchRequest.returnsObjectsAsFaults = false` and saving the managed object context properly
- Your Objects and Relationships are available in first run and is missing once you restart/relaunch the app Or sometimes few objects and relationships are randomly available and starts missing in subsequent runs
- You dont have any other errors while saving the managed object context
- The objects are missing where you dont have an inverse relationship and Xcode is also indicating a warning about missing inverse relationship

## When does it happen
Most of the cases have similar pattern. Check if it suits you
- A has one to many relationship with B. B doesnt have any inverse relationship
- B's objects are inserted first and saved to store
- A's objects are created in context, B's objects are fetched and is mapped to A
- When you save the context, it would appear A is saved, along with its relationship to B objects
- But when you fetch immediately from Store, you can see A's relationship to B is missing and you will not be able to access B objects from A

## Solution
There are 2 solutions.
- B should have an inverse relationship to A. ( Recommended if its possible.)

(or)

- Ensure that A object is first saved to store, as soon as its created.
- Now fetch A's object and map it to existing B objects and save it to store.
- When you fetch/refresh A's object, you will be able to access B objects despite not having an inverse relationship

## Projects in this repo
There are 2 projects in this repo to demonstrate the above solution
1. OneToMany-NotWorking  - to demonstrate why its not working
1. OneToMany-Working - to demonstrate how to make it working

### Citation
Please provide citation to this repo in stackoverflow or wherever required. 

### If it helped you
 :beers: Write me a quick and simple recommendation for me in [linkedin](https://in.linkedin.com/in/dhilipr)
