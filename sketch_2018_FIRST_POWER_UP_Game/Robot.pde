class Robot
{
  PVector position, velocity, acceleration;
  float w, h;
  float angle, a_velocity, a_acceleration;
  color robotColor;
  
  Robot(float x, float y, float w, float h, float angle, color robotColor)
  {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    
    this.angle = angle;
    a_velocity = 0;
    a_acceleration = 0;
    
    this.w = w;
    this.h = h;
    
    this.robotColor = robotColor;
  }
  
  void update()
  {
    //Calculate Forces
    
    //Apply all of the forces to the position
    this.velocity.add(acceleration);
    this.position.add(velocity);
    
    //Reset the acceleration
    this.acceleration.mult(0);
  }
  
  void draw()
  {
    pushMatrix();
    
    translate(position.x, position.y);
    rotate(angle);
    
    fill(this.robotColor);
    rect(0, 0, w, h);
    
    popMatrix();
  }
}