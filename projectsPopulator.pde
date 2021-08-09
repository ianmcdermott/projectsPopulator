// Projects Populator
// Helps Ian McD Design a sheet of IMD Project Descriptions
// August 8, 2021

import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import processing.pdf.*;

// A reference to our box2d world
Box2DProcessing box2d;

// A list we'll use to track fixed objects
ArrayList<Boundary> boundaries;
// A list for all of our rectangles
ArrayList<Category> categories;

// JSON Objects
JSONArray projJSON;
JSONArray catJSON;

int randSpread = 5;
float pixelScale = 1.5;
PImage textImage;

boolean saveOneFrame = true;

void setup() {
  size(918, 1188);
  smooth();
  textImage = loadImage("data/projects.png");

  projJSON = loadJSONArray("projects.json");
  catJSON = loadJSONArray("categories.json");

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  // Sideways gravity
  box2d.setGravity(20, 0);

  // Create ArrayLists	
  categories = new ArrayList<Category>();
  boundaries = new ArrayList<Boundary>();

  // Instatiate using JSON Data
  loadBoundaryFromJson();
  loadCategoryFromJson();
}


void draw() {
  background(255);
  image(textImage, 0, 0);

  if (saveOneFrame == true) {
    beginRecord(PDF, "shapesExport.pdf");
  }
  box2d.step();

  // Display all the categories
  for (Category b : categories) {
    b.display();
  }

  // Categoryes that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list
  for (int i = categories.size()-1; i >= 0; i--) {
    Category b = categories.get(i);
    if (b.done()) {
      categories.remove(i);
    }
  }

  if (saveOneFrame == true) {
    endRecord();
    saveOneFrame = false;
    println("exported frame");
  }
}

void loadCategoryFromJson() {
  //catJSON.getInt("id");
  for (int i = 0; i < projJSON.size(); i++) {
    //Get the array of types within projects object
    for (int j = 0; j < projJSON.getJSONObject(i).getJSONArray("type-id").size(); j++) {
      //create box for each category
      JSONObject typeObj = catJSON.getJSONObject(projJSON.getJSONObject(i).getJSONArray("type-id").getInt(j));
      Category p = new Category(random(-1000, -10), projJSON.getJSONObject(i).getInt("y")*pixelScale+(int) random(-randSpread, randSpread), typeObj.getString("category"), typeObj.getString("name"), unhex("FF"+typeObj.getString("color")));
      categories.add(p);
    }
  }
}

void loadBoundaryFromJson() {
  //catJSON.getInt("id");
  for (int i = 0; i < projJSON.size(); i++) {
    //Get the array of types within projects object
    for (int j = 0; j < projJSON.getJSONObject(i).getJSONArray("type-id").size(); j++) {
      //create boundary for each category
      boundaries.add(new Boundary(138*pixelScale, projJSON.getJSONObject(i).getInt("y")*pixelScale, 5*pixelScale, projJSON.getJSONObject(i).getInt("height")*1.1*pixelScale));
      boundaries.add(new Boundary(0, (projJSON.getJSONObject(i).getInt("y")-projJSON.getJSONObject(i).getInt("height")*1.1/2 )*pixelScale, 300*pixelScale, 5*pixelScale));
      boundaries.add(new Boundary(0, (projJSON.getJSONObject(i).getInt("y")+projJSON.getJSONObject(i).getInt("height")*1.1/2)*pixelScale, 300*pixelScale, 5*pixelScale));
    }
  }
}

// Regenerate Categories
void mousePressed() {
  for (int i = categories.size()-1; i >= 0; i--) {
    Category b = categories.get(i);
    b.killBody();
    categories.remove(i);
  }
  categories.clear();
  loadCategoryFromJson();
}


void keyPressed() {
  if (key == ' ' ) {
    saveOneFrame = true;
  }
}
