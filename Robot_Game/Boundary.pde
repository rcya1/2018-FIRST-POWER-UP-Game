class Boundary
{
  float w, h;
  boolean counted;
  
  Body body;
  
  Boundary(float x, float y, float w, float h)
  {
    this.w = w;
    this.h = h;

    counted = false;
    
    BodyDef bodyDef = new BodyDef();
    bodyDef.type = BodyType.STATIC;
    bodyDef.position = box2D.coordPixelsToWorld(x, y);
    
    body = box2D.createBody(bodyDef);
    
    PolygonShape shape = new PolygonShape();
    float box2DWidth = box2D.scalarPixelsToWorld(w);
    float box2DHeight = box2D.scalarPixelsToWorld(h);
    shape.setAsBox(box2DWidth / 2, box2DHeight / 2);
    
    FixtureDef fixtureDef = new FixtureDef();
    fixtureDef.shape = shape;
    fixtureDef.density = 1.0;
    fixtureDef.friction = 0.3;
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