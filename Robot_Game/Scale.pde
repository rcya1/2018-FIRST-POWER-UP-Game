class Scale
{
  PVector position;
  float w, h;
  
  Scale(float x, float y, float w, float h)
  {
    position = new PVector(x, y);
    this.w = w;
    this.h = h;
  }
  
  void update(ArrayList<Cube> cubes)
  {
    if(frameCount % FPS == 0)
    {
      int topCount = 0, bottomCount = 0;
      Area top = getTopArea();
      Area bottom = getBottomArea();
      
      for(Cube cube : cubes)
      {
        Area cubeArea = cube.getArea();
        if(intersects(top, cubeArea)) topCount++;
        else if(intersects(bottom, cubeArea)) bottomCount++;
      }
      
      if(topCount > bottomCount) score[0]++;
      if(topCount < bottomCount) score[1]++;
    }
  }
  
  void draw()
  {
    rectMode(CENTER);
    fill(100);
    rect(position.x, position.y, w, h - w * 2);
    fill(255, 0, 0);
    rect(position.x, position.y - h / 2 + w / 2, w, w);
    fill(0, 0, 255);
    rect(position.x, position.y + h / 2 - w / 2, w, w);
  }
  
  boolean intersects(Area area1, Area area2)
  {
    if(area1 == null || area2 == null) return false;
    return area1.intersects(area2.getBounds()) && area2.intersects(area1.getBounds());
  }
  
  Area getArea()
  {
    return new Area(new Rectangle((int) (position.x - w / 2), (int) (position.y - h / 2 + w), (int) w, (int) (h - w * 2)));
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