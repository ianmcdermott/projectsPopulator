// The Nature of Code
// <http://www.shiffman.net/teaching/nature>
// Spring 2012
// Modified by Ian McDermott
// August 8, 2021

// A rectangular box
class Category {

  // We need to keep track of a Body and a width and height
  Body body;
  float w;
  float h;
  float r;
  String type;
  String name;
  color col;
  int padding = 5;

  // Constructor
  Category(float x, float y, String t, String n, color c) {
    w = 7*pixelScale;
    h = 14*pixelScale;
    r = 6*pixelScale;
    type = t;
    name = n;
    col = c;
    // Add the box to the box2d world
    makeBody(new Vec2(x, y), w, h);
  }


  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  // Is the particle ready for deletion?
  boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);  
    // Is it off the bottom of the screen?
    if (pos.y > height+w*h) {
      killBody();
      return true;
    }
    return false;
  }

  void applyForce(Vec2 force) {
    Vec2 pos = body.getWorldCenter();
    body.applyForce(force, pos);
  }

  // Drawing the box
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    fill(col);
    noStroke();

    if (type.equals("tools")) {
      // Define a polygon (this is what we use for a rectangle)
      rectMode(CENTER);
      pushMatrix();
      translate(pos.x, pos.y);
      rotate(-a);
      rect(0, 0, w-padding, h-padding);
      popMatrix();
    } else  if (type.equals("skills")) {
      ellipseMode(CENTER);
      pushMatrix();
      translate(pos.x, pos.y);
      rotate(-a);
      ellipse(0, 0, r*2-padding, r*2-padding);
      popMatrix();
    }
  }

  // This function adds the rectangle to the box2d world
  void makeBody(Vec2 center, float w_, float h_) {
    FixtureDef fd = new FixtureDef();

    if (type.equals("tools")) {
      // Define a polygon (this is what we use for a rectangle)
      PolygonShape sd = new PolygonShape();
      float box2dW = box2d.scalarPixelsToWorld(w_/2);
      float box2dH = box2d.scalarPixelsToWorld(h_/2);
      sd.setAsBox(box2dW, box2dH);

      // Define a fixture
      fd.shape = sd;
    } else  if (type.equals("skills")) {
      CircleShape sd = new CircleShape();
      sd.m_radius = box2d.scalarPixelsToWorld(r);
      // Define a fixture
      fd.shape = sd;
    }


    // Parameters that affect physics
    fd.density = 0.6;
    fd.friction = 0.3;
    fd.restitution = 0.5;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    bd.angle = random(TWO_PI);

    body = box2d.createBody(bd);
    body.createFixture(fd);
  }
}

  
