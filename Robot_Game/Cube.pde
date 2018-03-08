class Cube
{
  float w, h;
  boolean counted;
  
  Body body;
  
  Cube(float x, float y)
  {
    this.w = width / 55;
    this.h = width / 55;
    
    counted = false;
    
    BodyDef bodyDef = new BodyDef();
    bodyDef.type = BodyType.DYNAMIC;
    bodyDef.position = box2D.coordPixelsToWorld(x, y);
    bodyDef.linearDamping = 1.5;
    bodyDef.angularDamping = 1.5;
    
    body = box2D.createBody(bodyDef);
    
    PolygonShape shape = new PolygonShape();
    float box2DWidth = box2D.scalarPixelsToWorld(w);
    float box2DHeight = box2D.scalarPixelsToWorld(h);
    shape.setAsBox(box2DWidth / 2, box2DHeight / 2);
    
    FixtureDef fixtureDef = new FixtureDef();
    fixtureDef.shape = shape;
    fixtureDef.density = 2.0;
    fixtureDef.friction = 1.0;
    fixtureDef.restitution = 0.5;
    
    body.createFixture(fixtureDef);
  }
  
  void update()
  {
    
  }
  
  void draw()
  {
    pushMatrix();
    
    rectMode(CENTER);
    fill(255, 255, 0);
    Vec2 loc = box2D.getBodyPixelCoord(body);
    translate(loc.x, loc.y);
    rotate(-body.getAngle());
    rect(0, 0, w, h);
    
    popMatrix();
    
    //fill(255, 0, 0, 50);
    //ellipse(position.x, position.y, sqrt(checkDistance), sqrt(checkDistance));
  }
}