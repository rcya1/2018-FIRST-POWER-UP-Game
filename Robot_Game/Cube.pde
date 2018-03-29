class Cube
{
  float w, h;
  boolean counted;
  
  BodyDef bodyDef;
  Body body;
  FixtureDef fixtureDef;  

  Vec2 lastPosition;
  boolean destroyed;
  boolean raised;
  
  Cube(float x, float y)
  {
    this.w = width / 55;
    this.h = width / 55;
    
    counted = false;
    
    bodyDef = new BodyDef();
    bodyDef.type = BodyType.DYNAMIC;
    bodyDef.position = box2D.coordPixelsToWorld(x, y);
    bodyDef.linearDamping = 1.5;
    bodyDef.angularDamping = 1.5;
    
    body = box2D.createBody(bodyDef);
    
    PolygonShape shape = new PolygonShape();
    float box2DWidth = box2D.scalarPixelsToWorld(w);
    float box2DHeight = box2D.scalarPixelsToWorld(h);
    shape.setAsBox(box2DWidth / 2, box2DHeight / 2);
    
    fixtureDef = new FixtureDef();
    fixtureDef.shape = shape;
    fixtureDef.density = 2.0;
    fixtureDef.friction = 1.0;
    fixtureDef.restitution = 0.5;

    fixtureDef.filter.categoryBits = CATEGORY_CUBE_NORMAL;
    fixtureDef.filter.maskBits = MASK_CUBE_NORMAL;

    fixtureDef.setUserData(this);
    
    body.createFixture(fixtureDef);

    lastPosition = new Vec2();
    destroyed = false;
  }
  
  void update()
  {
    
  }
  
  void draw()
  {
    pushMatrix();
    
    rectMode(CENTER);
    fill(255, 255, 0);
    Vec2 loc = destroyed ? lastPosition : box2D.getBodyPixelCoord(body);
    lastPosition = loc;
    translate(loc.x, loc.y);
    rotate(-body.getAngle());
    rect(0, 0, w, h);
    
    popMatrix();
    
    //fill(255, 0, 0, 50);
    //ellipse(position.x, position.y, sqrt(checkDistance), sqrt(checkDistance));
  }

  void removeFromWorld()
  {
    if(body != null) box2D.destroyBody(body);
    destroyed = true;
  }

  void addToWorld(PVector position, float angle)
  {
    bodyDef.position = box2D.coordPixelsToWorld(position);
    bodyDef.angle = angle;
    body = box2D.createBody(bodyDef);
    body.createFixture(fixtureDef);
    destroyed = false;
  }

  void setCollisionToScale()
  {
    Filter filter = new Filter();
    filter.categoryBits = CATEGORY_CUBE_SCALE;
    filter.maskBits = MASK_CUBE_SCALE;
    body.getFixtureList().setFilterData(filter);
  }

  void setCollisionToNormal()
  {
    Filter filter = new Filter();
    filter.categoryBits = CATEGORY_CUBE_NORMAL;
    filter.maskBits = MASK_CUBE_NORMAL;
    body.getFixtureList().setFilterData(filter);
  }
}