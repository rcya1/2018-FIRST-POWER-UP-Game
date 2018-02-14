class Robot
{
  PVector position, velocity, acceleration;
  float w, h;
  float angle, a_velocity, a_acceleration;
  color robotColor, intakeColor;
  
  Rectangle rectangle;    //Nonrotated
  Rectangle frontRectangle;
  Area collisionBox;      //Rotated
  Area frontCollisionBox; //Front Box Rotated
  
  float speed;
  float a_speed;
  
  float maxSpeed;
  
  Cube cube;
  
  boolean intakeActive;
  boolean canIntake;
  
  boolean strafeDrive;
  
  boolean wasd;
  
  Robot oppRobot;
  
  //TODO Optimize this
  Robot(float x, float y, float w, float h, float angle, color robotColor, color intakeColor, boolean wasd)
  {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    
    this.angle = angle;
    a_velocity = 0;
    a_acceleration = 0;
    
    this.speed = width / 1000.0;
    this.a_speed = 0.5;
    
    this.maxSpeed = width / 200.0;
    
    this.w = w;
    this.h = h;
    
    this.rectangle = new Rectangle((int) position.x - width / 2, (int) position.y - height / 2, (int) w, (int) h);
    
    this.robotColor = robotColor;
    this.intakeColor = intakeColor;
    this.cube = null;
    
    this.intakeActive = false;
    this.canIntake = true;
    
    this.strafeDrive = false;
    this.wasd = wasd;
  }
  
  void update(ArrayList<Area> objects, ArrayList<Cube> cubes, ArrayList<Balance> balances)
  {
    updateCollisionBox();
    
    //Calculate Forces
    calculateAirResistance();
    
    updatePositions(objects, cubes, balances);
    if(intakeActive && canIntake && this.cube == null) checkIntake(cubes, balances);
    if(intakeActive && canIntake && this.cube != null) ejectCube(objects, cubes, balances);
    
    if(this.cube != null) updateCubePosition();
  }
  
  void updateCollisionBox()
  {
    rectangle.setLocation((int) (position.x - w / 2), (int) (position.y - h / 2));
    collisionBox = new Area(rectangle);
    
    frontRectangle = new Rectangle((int) (position.x - w / 4), (int) (position.y - h / 2.0 - 1), (int) w / 2, (int) h / 4);
    frontCollisionBox = new Area(frontRectangle);
    
    AffineTransform transform = new AffineTransform();
    transform.rotate(radians(angle), position.x, position.y);
    
    collisionBox.transform(transform);
    frontCollisionBox.transform(transform);
  }
  
  void calculateAirResistance()
  {
    applyAngularForce(-0.1 * a_velocity);
    applyForce(PVector.mult(velocity, -0.1));
  }
  
  void updatePositions(ArrayList<Area> objects, ArrayList<Cube> cubes, ArrayList<Balance> balances)
  {
    Area unified = new Area();
    for(Area area : objects)
    {
      unified.add(area);
    }
    int DIVISIONS = 200;
    
    if(velocity.magSq() > maxSpeed * maxSpeed) velocity.setMag(maxSpeed);
    if(velocity.magSq() < 0.01) velocity.mult(0);
    
    //Apply all of the forces to the position
    this.velocity.add(acceleration);
    
    PVector move = PVector.div(this.velocity, DIVISIONS);
    for(int i = 0; i < DIVISIONS; i++)
    {
      this.position.add(move);
      updateCollisionBox();
      if(intersects(unified))
      {
        this.position.sub(move);
        break;
      }
      
      if(oppRobot != null)
      {
        if(intersects(oppRobot.collisionBox))
        {
          this.position.sub(move);
        }
      }
      
      for(Balance balance : balances)
      {
        if(intersects(balance.getArea()))
        {
          this.position.sub(move);
          break;
        }
      }
      
      for(Cube cube : cubes)
      {
        if(!cube.used)
        {
          boolean flag = false;
          for(Balance balance : balances)
          {
            if(cube.intersects(balance.getTopArea()) || cube.intersects(balance.getBottomArea()))
            {
              flag = true;
              break;
            }
          }
          
          if(!flag)
          {
            if(intersects(cube.getArea()))
            {
              this.position.sub(move);
              break;
            }
          }
        }
      }
    }
    
    this.a_velocity += this.a_acceleration;
    float moveAngle = this.a_velocity / DIVISIONS;
    for(int i = 0; i < DIVISIONS; i++)
    {
      this.angle += moveAngle;
      updateCollisionBox();
      if(intersects(unified))
      {
        this.angle -= moveAngle;
        break;
      }
      
      if(oppRobot != null)
      {
        if(intersects(oppRobot.collisionBox))
        {
          this.angle -= moveAngle;
        }
      }
      
      for(Balance balance : balances)
      {
        if(intersects(balance.getArea()))
        {
          this.angle -= moveAngle;
          break;
        }
      }
      
      for(Cube cube : cubes)
      {
        if(!cube.used)
        {
          boolean flag = false;
          for(Balance balance : balances)
          {
            if(cube.intersects(balance.getTopArea()) || cube.intersects(balance.getBottomArea()))
            {
              flag = true;
              break;
            }
          }
          
          if(!flag)
          {
            if(intersects(cube.getArea()))
            {
              this.angle -= moveAngle;
              break;
            }
          }
        }
      }
    }
    
    angle = angle % 360;
    if(angle < 0) angle += 360;
    if(abs(a_velocity) < 0.001) a_velocity = 0;
    
    //Reset the acceleration
    this.acceleration.mult(0);
    this.a_acceleration = 0;
  }
  
  void checkIntake(ArrayList<Cube> cubes, ArrayList<Balance> balances)
  {
    Iterator<Cube> iterator = cubes.iterator();
    while(iterator.hasNext())
    {
      Cube cube = (Cube) iterator.next();
      if(!cube.used)
      {
        if(intersectsFront(cube.getArea()))
        {
          boolean flag = false;
          for(Balance balance : balances)
          {
            if(cube.intersects(balance.getTopArea()) || cube.intersects(balance.getBottomArea()))
            {
              flag = true;
              break;
            }
          }
          
          if(!flag)
          {
            this.cube = cube;
            iterator.remove();
            intakeActive = false;
            canIntake = false;
            break;
          }
        }
      }
    }
  }
  
  void ejectCube(ArrayList<Area> areas, ArrayList<Cube> cubes, ArrayList<Balance> balances)
  {
    Area unified = new Area();
    for(Area area : areas)
    {
      unified.add(area);
    }
    if(!this.cube.intersects(unified, cubes, oppRobot, balances))
    {
      for(Balance balance : balances)
      {
        if(this.cube.intersects(balance.getBottomArea()) || this.cube.intersects(balance.getTopArea())) this.cube.used = true;
        else this.cube.used = false;
        
        cubes.add(cube);
        this.cube = null;
        this.canIntake = false;
        break;
      }
    }
  }
  
  void updateCubePosition()
  {
    this.cube.position = PVector.add(position, PVector.fromAngle(radians(angle - 90)).mult(h * 3 / 4.0));
  }
  
  void applyForce(PVector force)
  {
    acceleration.add(force);
  }
  
  void applyAngularForce(double force)
  {
    a_acceleration += force;
  }
  
  void draw()
  {
    pushMatrix();
    
    translate(position.x, position.y);
    rotate(radians(angle));
    
    fill(this.robotColor);
    rectMode(CENTER);
    rect(0, 0, w, h);
    
    popMatrix();
    
    drawArea(frontCollisionBox, intakeColor);
  }
  
  void input(HashSet<Character> keys, HashSet<Integer> keyCodes)
  {
    strafeDrive = (keyCodes.contains(SHIFT) && wasd) || ((keys.contains('/') || keys.contains('?')) && !wasd);
    
    if(!strafeDrive) normalControl(keys, keyCodes);
    else strafeControl(keys, keyCodes, false);
    
    intakeActive = (keys.contains(' ') && wasd) || ((keys.contains('.') || keys.contains('>')) && !wasd);
    if(!((keys.contains(' ') && wasd) || ((keys.contains('.') || keys.contains('>')) && !wasd))) canIntake = true;
  }
  
  void normalControl(HashSet<Character> keys, HashSet<Integer> keyCodes)
  {
    if((keys.contains('d') && wasd) || (keyCodes.contains(RIGHT) && !wasd)) applyAngularForce(a_speed);
    if((keys.contains('a') && wasd) || (keyCodes.contains(LEFT) && !wasd)) applyAngularForce(-a_speed);
    if((keys.contains('w') && wasd) || (keyCodes.contains(UP) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(radians(angle - 90)).mult(speed);
      applyForce(moveForce);
    }
    if((keys.contains('s') && wasd) || (keyCodes.contains(DOWN) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(radians(angle - 90 + 180)).mult(speed);
      applyForce(moveForce);
    }
  }
  
  void strafeControl(HashSet<Character> keys, HashSet<Integer> keyCodes, boolean firstPerson)
  {
    float referenceAngle = firstPerson ? angle - 90 : -90;
    if((keys.contains('d') && wasd) || (keyCodes.contains(RIGHT) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(radians(referenceAngle + 90)).mult(speed / 3.0);
      applyForce(moveForce);
    }
    if((keys.contains('a') && wasd) || (keyCodes.contains(LEFT) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(radians(referenceAngle - 90)).mult(speed / 3.0);
      applyForce(moveForce);
    }
    if((keys.contains('w') && wasd) || (keyCodes.contains(UP) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(radians(referenceAngle)).mult(speed / 3.0);
      applyForce(moveForce);
    }
    if((keys.contains('s') && wasd) || (keyCodes.contains(DOWN) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(radians(referenceAngle + 180)).mult(speed / 3.0);
      applyForce(moveForce);
    }
  }
  
  boolean intersects(Area other)
  {
    if(other == null) return false;
    return collisionBox.intersects(other.getBounds()) && other.intersects(collisionBox.getBounds());
  }
  
  boolean intersectsFront(Area other)
  {
    if(other == null) return false;
    return frontCollisionBox.intersects(other.getBounds()) && other.intersects(frontCollisionBox.getBounds());
  }
  
  void setOppRobot(Robot robot)
  {
    this.oppRobot = robot;
  }
}