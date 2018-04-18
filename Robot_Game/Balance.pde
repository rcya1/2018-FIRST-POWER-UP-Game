class Balance
{
  PVector position;
  float w, h;
  boolean isScale;
  boolean redTop;
  boolean left;
  
  int topCount;
  int bottomCount;
  
  int prevTime;
  
  Body body;

  static final float DENSITY = 5.0;
  static final float RESTITUTION = 0.01;
  static final float FRICTION = 1.0;
  
  Balance(float x, float y, float w, float h, boolean isScale, boolean redTop, boolean left)
  {
    position = new PVector(x, y);
    this.w = w;
    this.h = h;
    
    this.isScale = isScale;
    this.redTop = redTop;
    this.left = left;
    
    this.topCount = 0;
    this.bottomCount = 0;
    
    this.prevTime = millis();

    setupBox2D(x, y);
  }

  void setupBox2D(float x, float y)
  {
    BodyDef bodyDef = new BodyDef();
    bodyDef.type = BodyType.STATIC;
    bodyDef.position = box2D.coordPixelsToWorld(x, y);
    
    body = box2D.createBody(bodyDef);

    PolygonShape middleShape = new PolygonShape();
    float box2DWidth = box2D.scalarPixelsToWorld(isScale ? w / 2 : w);
    float box2DHeight = box2DHeight = box2D.scalarPixelsToWorld(h - w * 2); 
    middleShape.setAsBox(box2DWidth / 2, box2DHeight / 2);
    
    createFixture(middleShape, false);

    float scaleFenceWidth = isScale ? 0.0 : 4.0;
    
    PolygonShape topShape = new PolygonShape();
    box2DWidth = box2D.scalarPixelsToWorld(w);
    box2DHeight = box2D.scalarPixelsToWorld(scaleFenceWidth);
    Vec2 offset = box2D.vectorPixelsToWorld(0, -h / 2.0 + scaleFenceWidth / 2);

    topShape.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);
    createFixture(topShape, isScale);


    PolygonShape bottomShape = new PolygonShape();
    box2DWidth = box2D.scalarPixelsToWorld(w);
    box2DHeight = box2D.scalarPixelsToWorld(scaleFenceWidth);
    offset = box2D.vectorPixelsToWorld(0, h / 2.0 - scaleFenceWidth / 2);

    bottomShape.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);
    createFixture(bottomShape, isScale);


    PolygonShape leftShape = new PolygonShape();
    box2DWidth = box2D.scalarPixelsToWorld(scaleFenceWidth);
    box2DHeight = box2D.scalarPixelsToWorld(h);
    offset = box2D.vectorPixelsToWorld(-w / 2.0 + scaleFenceWidth / 2, 0);

    leftShape.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);
    createFixture(leftShape, isScale);


    PolygonShape rightShape = new PolygonShape();
    box2DWidth = box2D.scalarPixelsToWorld(scaleFenceWidth);
    box2DHeight = box2D.scalarPixelsToWorld(h);
    offset = box2D.vectorPixelsToWorld(w / 2.0 - scaleFenceWidth / 2, 0);

    rightShape.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);
    createFixture(rightShape, isScale);


    PolygonShape topShapeCheck = new PolygonShape();
    box2DWidth = box2D.scalarPixelsToWorld(w - scaleFenceWidth * 2);
    box2DHeight = box2D.scalarPixelsToWorld(w - scaleFenceWidth * 2);
    offset = box2D.vectorPixelsToWorld(0, -h / 2 + w / 2);
    topShapeCheck.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);

    FixtureDef topShapeFixtureDef = new FixtureDef();
    topShapeFixtureDef.shape = topShapeCheck;
    topShapeFixtureDef.density = DENSITY;
    topShapeFixtureDef.friction = FRICTION;
    topShapeFixtureDef.restitution = RESTITUTION;
    topShapeFixtureDef.isSensor = true;
    topShapeFixtureDef.setUserData(new BalanceCollision(true, this));

    body.createFixture(topShapeFixtureDef);

    PolygonShape bottomShapeCheck = new PolygonShape();
    box2DWidth = box2D.scalarPixelsToWorld(w - scaleFenceWidth * 2);
    box2DHeight = box2D.scalarPixelsToWorld(w - scaleFenceWidth * 2);
    offset = box2D.vectorPixelsToWorld(0, h / 2 - w / 2);
    bottomShapeCheck.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);

    FixtureDef bottomShapeFixtureDef = new FixtureDef();
    bottomShapeFixtureDef.shape = bottomShapeCheck;
    bottomShapeFixtureDef.density = DENSITY;
    bottomShapeFixtureDef.friction = FRICTION;
    bottomShapeFixtureDef.restitution = RESTITUTION;
    bottomShapeFixtureDef.isSensor = true;
    bottomShapeFixtureDef.setUserData(new BalanceCollision(false, this));

    body.createFixture(bottomShapeFixtureDef);
  }

  void createFixture(PolygonShape shape, boolean isScaleBorder)
  {
    FixtureDef fixtureDef = new FixtureDef();
    fixtureDef.shape = shape;
    fixtureDef.density = DENSITY;
    fixtureDef.friction = FRICTION;
    fixtureDef.restitution = RESTITUTION;

    if(isScaleBorder)
    {
      fixtureDef.filter.categoryBits = CATEGORY_SCALE_BORDER;
      fixtureDef.filter.maskBits = MASK_SCALE_BORDER;
    }
    
    body.createFixture(fixtureDef);
  }
  
  void update(ArrayList<Cube> cubes)
  {
    if(timer != 0 && countDown == 0)
    {
      int time = millis();
      if(time - prevTime >= 1000)
      {
        prevTime = time;
        if(isScale) timer--;
        
        if(topCount > bottomCount)
        {
          if(isScale)
          {
            if(redTop) score[0]++;
            else score[1]++;
          }
          else
          {
            if(left && redTop) score[0]++;
            else if(!left && !redTop) score[1]++;
          }
        }
        if(topCount < bottomCount)
        {
          if(isScale)
          {
            if(redTop) score[1]++;
            else score[0]++;
          }
          else
          {
            if(left && !redTop) score[0]++;
            else if(!left && redTop) score[1]++;
          }
        }
      }
    }
  }
  
  void draw()
  {
    rectMode(CENTER);
    
    fill(100);
    rect(position.x, position.y, isScale ? w / 2 : w, h - w * 2);
    
    //Set appropriate colors. Draw switch slightly lighter
    if(redTop)
    {
      if(isScale) fill(255, 25, 25);
      else fill(255, 0, 0);
    }
    else
    {
      if(isScale) fill(25, 25, 255);
      else fill(0, 0, 255);
    }
    rect(position.x, position.y - h / 2 + w / 2, w, w);
    
    if(!redTop)
    {
      if(isScale) fill(255, 25, 25);
      else fill(255, 0, 0);
    }
    else
    {
      if(isScale) fill(25, 25, 255);
      else fill(0, 0, 255);
    }
    rect(position.x, position.y + h / 2 - w / 2, w, w);
  }
  
  void drawShadows()
  {
    noStroke();
    fill(100, 100);
    rect(position.x + 2, position.y - h / 2 + w / 2 - 2, w + 3, w + 2);
    rect(position.x + 2, position.y + h / 2 - w / 2 - 2, w + 3, w + 2);
    //drawCenterGradient(position.x, position.y - h / 2 + w / 2, w + 4, w + 4, color(0), color(200));
    //drawCenterGradient(position.x, position.y + h / 2 - w / 2, w + 4, w + 4, color(0), color(100));
    stroke(0);
  }
  
  //WAY TOO LAGGY
  //void drawCenterGradient(float x, float y, float w, float h, color center, color expand)
  //{
  //  float maxDistanceSq = w * w / 4 + h * h / 4;
  //  for(int col = int(x - w / 2); col <= int(x + w / 2); col++)
  //  {
  //    for(int row = int(y - h / 2); row <= int(y + h / 2); row++)
  //    {
  //      float distSq = (col - x) * (col - x) + (row - y) * (row - y);
  //      //float distSq = 
  //      stroke(lerpColor(center, expand, distSq / maxDistanceSq));
  //      point(col, row);
  //    }
  //  }
  //  stroke(0);
  //}

  void incrementCount(boolean top)
  {
    if(top) topCount++;
    else bottomCount++;
  }

  void decrementCount(boolean top)
  {
    if(top) topCount--;
    else topCount++;
  }

  void removeFromWorld()
  {
    if(body != null) box2D.destroyBody(body);
  }
}