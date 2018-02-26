class Cube
{
  PVector position;
  float w, h;
  boolean counted;
  
  float checkDistance;
  
  Cube(float x, float y)
  {
    position = new PVector(x, y);
    this.w = width / 55;
    this.h = width / 55;
    
    counted = false;
    
    this.checkDistance = max(this.w, this.h) * max(this.w, this.h) * 2;
  }
  
  void update()
  {
    
  }
  
  void draw()
  {
    rectMode(CENTER);
    fill(255, 255, 0);
    rect(position.x, position.y, w, h);
  }
  
  Area getArea()
  {
    return new Area(new Rectangle((int) (position.x - w / 2), (int) (position.y - h / 2), (int) w, (int) h));
  }
  
  boolean intersects(Area other)
  {
    if(other == null) return false;
    Area collisionBox = getArea();
    return collisionBox.intersects(other.getBounds()) && other.intersects(collisionBox.getBounds());
  }
  
  boolean intersects(Area area, ArrayList<Cube> cubes, Robot robot, ArrayList<Balance> balances)
  {
    if(intersects(area) || intersects(robot.collisionBox)) return true;
    for(Cube cube : cubes)
    {
      if(!cube.counted)
      {
        if(PVector.sub(this.position, cube.position).magSq() <= this.checkDistance)
        {
          if(intersects(cube.getArea())) return true;
        }
      }
    }
    for(Balance balance : balances)
    {
      if(PVector.sub(this.position, balance.position).magSq() <= this.checkDistance)
      {
        if(intersects(balance.getArea()))
        {
          if(!intersects(balance.getTopArea()) && !intersects(balance.getBottomArea())) return true;
        }
      }
    }
    return false;
  }
}