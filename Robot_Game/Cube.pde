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
    
    //fill(255, 0, 0, 50);
    //ellipse(position.x, position.y, sqrt(checkDistance), sqrt(checkDistance));
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
        if(PVector.sub(this.position, cube.position).magSq() <= this.checkDistance + cube.checkDistance)
        {
          if(intersects(cube.getArea())) return true;
        }
      }
    }
    
    Balance checkBalance = null;
    
    if(position.x < width / 3)
    {
      checkBalance = balances.get(LEFT_SWITCH);
    }
    else if(position.x > width * 2.0 / 3)
    {
      checkBalance = balances.get(RIGHT_SWITCH);
    }
    else checkBalance = balances.get(SCALE);
    
    if(PVector.sub(this.position, checkBalance.position).magSq() <= this.checkDistance + checkBalance.checkDistance)
    {
      if(intersects(checkBalance.getArea()))
      {
        if(!intersects(checkBalance.getTopArea()) && !intersects(checkBalance.getBottomArea())) return true;
      }
    }
    
    return false;
  }
}