class Balance
{
  PVector position;
  float w, h;
  boolean isScale;
  boolean redTop;
  boolean left;
  
  int topCount;
  int bottomCount;
  
  float checkDistance;
  
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
    
    this.checkDistance = max(this.w, this.h) * max(this.w, this.h) * 2;
  }
  
  void update(ArrayList<Cube> cubes)
  {
    if(frameCount % FPS == 0)
    {
      Area top = getTopArea();
      Area bottom = getBottomArea();
      
      for(Cube cube : cubes)
      {
        if(!cube.counted)
        {
          if(PVector.sub(this.position, cube.position).magSq() <= this.checkDistance)
          {
            Area cubeArea = cube.getArea();
            if(intersects(top, cubeArea))
            {
              topCount++;
              cube.counted = true;
            }
            else if(intersects(bottom, cubeArea))
            {
              bottomCount++;
              cube.counted = true;
            }
          }
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