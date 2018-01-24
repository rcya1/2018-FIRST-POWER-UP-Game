class Robot
{
  PVector position, velocity, acceleration;
  float w, h;
  float angle, a_velocity, a_acceleration;
  color robotColor;
  
  float speed;
  float a_speed;
  
  Robot(float x, float y, float w, float h, float angle, color robotColor)
  {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    
    this.angle = angle;
    a_velocity = 0;
    a_acceleration = 0;
    
    this.speed = 0.75;
    this.a_speed = 0.5;
    
    this.w = w;
    this.h = h;
    
    this.robotColor = robotColor;
  }
  
  void update()
  {
    //Calculate Forces
    applyAngularForce(-0.1 * a_velocity); //Air Resistance
    applyForce(PVector.mult(velocity, -0.1)); //Air Resistance
    
    //Apply all of the forces to the position
    this.velocity.add(acceleration);
    this.position.add(velocity);
    
    this.a_velocity += this.a_acceleration;
    this.angle += this.a_velocity;
    
    angle = angle % 360;
    if(angle < 0) angle += 360;
    if(abs(a_velocity) < 0.001) a_velocity = 0;
    
    //Reset the acceleration
    this.acceleration.mult(0);
    this.a_acceleration = 0;
  }
  
  void applyForce(PVector force)
  {
    acceleration.add(force);
  }
  
  void applyAngularForce(double force)
  {
    a_acceleration += force;
  }
  
  void input(HashSet<Character> keys)
  {
    if(keys.contains('d')) applyAngularForce(a_speed);
    if(keys.contains('a')) applyAngularForce(-a_speed);
    if(keys.contains('w'))
    {
      PVector moveForce = PVector.fromAngle(radians(angle - 90)).mult(speed);
      applyForce(moveForce);
    }
    if(keys.contains('s'))
    {
      PVector moveForce = PVector.fromAngle(radians(angle - 90 + 180)).mult(speed);
      applyForce(moveForce);
    }
  }
  
  void draw()
  {
    pushMatrix();
    
    translate(position.x, position.y);
    rotate(radians(angle));
    
    fill(this.robotColor);
    rect(0, 0, w, h);
    
    popMatrix();
  }
}