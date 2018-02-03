class Cube
{
  PVector position;
  float w, h;
  
  Cube(float x, float y)
  {
    position = new PVector(x, y);
    this.w = 36;
    this.h = 36;
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
}