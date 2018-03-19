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
    
    BodyDef bodyDef = new BodyDef();
    bodyDef.type = BodyType.STATIC;
    bodyDef.position = box2D.coordPixelsToWorld(x, y);
    
    body = box2D.createBody(bodyDef);
    
    // PolygonShape shape = new PolygonShape();
    // float box2DWidth = box2D.scalarPixelsToWorld(w);
    // float box2DHeight = isScale ? box2D.scalarPixelsToWorld(h - w * 2) : box2D.scalarPixelsToWorld(h);
    // shape.setAsBox(box2DWidth / 2, box2DHeight / 2);

    PolygonShape middleShape = new PolygonShape();
    float box2DWidth = box2D.scalarPixelsToWorld(w);
    float box2DHeight = box2DHeight = box2D.scalarPixelsToWorld(h - w * 2); 
    middleShape.setAsBox(box2DWidth / 2, box2DHeight / 2);
    
    createFixture(middleShape);

    float scaleFenceWidth = 4.0;

    if(!isScale)
    { 
      PolygonShape topShape = new PolygonShape();
      box2DWidth = box2D.scalarPixelsToWorld(w);
      box2DHeight = box2D.scalarPixelsToWorld(scaleFenceWidth);
      Vec2 offset = box2D.vectorPixelsToWorld(0, -h / 2.0 + scaleFenceWidth / 2);

      topShape.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);
      createFixture(topShape);


      PolygonShape bottomShape = new PolygonShape();
      box2DWidth = box2D.scalarPixelsToWorld(w);
      box2DHeight = box2D.scalarPixelsToWorld(scaleFenceWidth);
      offset = box2D.vectorPixelsToWorld(0, h / 2.0 - scaleFenceWidth / 2);

      bottomShape.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);
      createFixture(bottomShape);


      PolygonShape leftShape = new PolygonShape();
      box2DWidth = box2D.scalarPixelsToWorld(scaleFenceWidth);
      box2DHeight = box2D.scalarPixelsToWorld(h);
      offset = box2D.vectorPixelsToWorld(-w / 2.0 + scaleFenceWidth / 2, 0);

      leftShape.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);
      createFixture(leftShape);


      PolygonShape rightShape = new PolygonShape();
      box2DWidth = box2D.scalarPixelsToWorld(scaleFenceWidth);
      box2DHeight = box2D.scalarPixelsToWorld(h);
      offset = box2D.vectorPixelsToWorld(w / 2.0 - scaleFenceWidth / 2, 0);

      rightShape.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);
      createFixture(rightShape);
    }

    PolygonShape topShape = new PolygonShape();
    box2DWidth = box2D.scalarPixelsToWorld(w - scaleFenceWidth * 2);
    box2DHeight = box2D.scalarPixelsToWorld(w - scaleFenceWidth * 2);
    Vec2 offset = box2D.vectorPixelsToWorld(0, -h / 4.0);
    topShape.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);

    FixtureDef topShapeFixtureDef = new FixtureDef();
    topShapeFixtureDef.shape = topShape;
    topShapeFixtureDef.density = 0.3;
    topShapeFixtureDef.friction = 0.3;
    topShapeFixtureDef.restitution = 0.5;
    topShapeFixtureDef.isSensor = true;
    topShapeFixtureDef.setUserData(new BalanceCollision(true, this));

    body.createFixture(topShapeFixtureDef);

    PolygonShape bottomShape = new PolygonShape();
    box2DWidth = box2D.scalarPixelsToWorld(w - scaleFenceWidth * 2);
    box2DHeight = box2D.scalarPixelsToWorld(w - scaleFenceWidth * 2);
    offset = box2D.vectorPixelsToWorld(0, h / 4.0);
    bottomShape.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);

    FixtureDef bottomShapeFixtureDef = new FixtureDef();
    bottomShapeFixtureDef.shape = bottomShape;
    bottomShapeFixtureDef.density = 0.3;
    bottomShapeFixtureDef.friction = 0.3;
    bottomShapeFixtureDef.restitution = 0.5;
    bottomShapeFixtureDef.isSensor = true;
    bottomShapeFixtureDef.setUserData(new BalanceCollision(false, this));

    body.createFixture(bottomShapeFixtureDef);
  }

  void createFixture(PolygonShape shape)
  {
    FixtureDef fixtureDef = new FixtureDef();
    fixtureDef.shape = shape;
    fixtureDef.density = 1.0;
    fixtureDef.friction = 0.3;
    fixtureDef.restitution = 0.5;
    
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
        
        Area top = getTopArea();
        Area bottom = getBottomArea();
        
        for(Cube cube : cubes)
        {
          if(!cube.counted)
          {
            //if(PVector.sub(this.position, cube.position).magSq() <= this.checkDistance + cube.checkDistance)
            //{
            //  Area cubeArea = cube.getArea();
            //  if(intersects(top, cubeArea))
            //  {
            //    topCount++;
            //    cube.counted = true;
            //  }
            //  else if(intersects(bottom, cubeArea))
            //  {
            //    bottomCount++;
            //    cube.counted = true;
            //  }
            //}
          }
        }
        
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
    rect(position.x, position.y, w, h - w * 2);
    
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
    
    //fill(255, 0, 0, 50);
    //ellipse(position.x, position.y, sqrt(checkDistance), sqrt(checkDistance));
  }
  
  void drawShadows()
  {
    noStroke();
    fill(200);
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
  
  boolean intersects(Area area1, Area area2)
  {
    if(area1 == null || area2 == null) return false;
    return area1.intersects(area2.getBounds()) && area2.intersects(area1.getBounds());
  }
  
  Area getArea()
  {
    if(isScale)
    {
      return new Area(new Rectangle((int) (position.x - w / 2), (int) (position.y - h / 2 + w), (int) w, (int) (h - w * 2)));
    }
    else
    {
      return new Area(new Rectangle((int) (position.x - w / 2), (int) (position.y - h / 2), (int) w, (int) h));
    }
  }
  
  Area getTopArea()
  {
      return new Area(new Rectangle((int) (position.x - w / 2), (int) (position.y - h / 2), (int) w, (int) w));
  }
  
  Area getBottomArea()
  {
      return new Area(new Rectangle((int) (position.x - w / 2), (int) (position.y + h / 2 - w), (int) w, (int) w));
  }
}