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
  
  float checkDistance;
  
  Robot(float x, float y, float w, float h, float angle, color robotColor, color intakeColor, boolean wasd)
  {
    position = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    
    this.angle = angle;
    a_velocity = 0;
    a_acceleration = 0;
    
    this.speed = width / 2000.0;
    this.a_speed = 0.3;
    
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
    
    this.checkDistance = max(this.w, this.h) * max(this.w, this.h) * 1.25;
  }
  
  void update(ArrayList<Area> objects, ArrayList<Cube> cubes, ArrayList<Balance> balances)
  {
    updateCollisionBox();
    
    //Calculate Forces
    calculateAirResistance();
    
    updatePositions(objects, cubes, balances);
    if(intakeActive && canIntake && this.cube == null) checkIntake(cubes);
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
        if(PVector.sub(this.position, oppRobot.position).magSq() <= this.checkDistance + oppRobot.checkDistance)
        {
          if(intersects(oppRobot.collisionBox))
          {
            this.position.sub(move);
            break;
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
          this.position.sub(move);
          break;
        }
      }
      
      for(Cube cube : cubes)
      {
        if(!cube.counted)
        {
          if(PVector.sub(this.position, cube.position).magSq() <= this.checkDistance + cube.checkDistance)
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
        if(PVector.sub(this.position, oppRobot.position).magSq() <= this.checkDistance + oppRobot.checkDistance)
        {
          if(intersects(oppRobot.collisionBox))
          {
            this.angle -= moveAngle;
            break;
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
          this.angle -= moveAngle;
          break;
        }
      }
      
      for(Cube cube : cubes)
      {
        if(!cube.counted)
        {
          if(PVector.sub(this.position, cube.position).magSq() <= this.checkDistance + cube.checkDistance)
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
  
  void checkIntake(ArrayList<Cube> cubes)
  {
    Iterator<Cube> iterator = cubes.iterator();
    while(iterator.hasNext())
    {
      Cube cube = (Cube) iterator.next();
      if(!cube.counted)
      {
        if(PVector.sub(this.position, cube.position).magSq() <= this.checkDistance + cube.checkDistance)
        {
          if(intersectsFront(cube.getArea()))
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
      cubes.add(cube);
      this.cube = null;
      this.canIntake = false;
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

    pushMatrix();
    
    translate(position.x, position.y);
    rotate(radians(angle));
    
    if(this.cube != null)
    {
      fill(255, 255, 0);
      rect(0, -h / 2.5, width / 55, width / 55);
    }
    
    popMatrix();
    
    //fill(255, 0, 0, 50);
    //ellipse(position.x, position.y, sqrt(checkDistance), sqrt(checkDistance));
  }
  
  void input(HashSet<Character> keys, HashSet<Integer> keyCodes, ControllerState controller)
  {
    if(controller.isConnected)
    {
      if(controller.a) normalControl(controller);
      else if(controller.lb) leftControl(controller);
      else if(controller.rb) rightControl(controller);
      else if(controller.x) strafeControl(controller);
      
      intakeActive = controller.b;
      if(!controller.b) canIntake = true;
    }
    else
    {
      strafeDrive = (keyCodes.contains(SHIFT) && wasd) || ((keys.contains('/') || keys.contains('?')) && !wasd);
      
      if(!strafeDrive) normalControl(keys, keyCodes);
      else strafeControl(keys, keyCodes, false);
      
      intakeActive = (keys.contains(' ') && wasd) || ((keys.contains('.') || keys.contains('>')) && !wasd);
      if(!((keys.contains(' ') && wasd) || ((keys.contains('.') || keys.contains('>')) && !wasd))) canIntake = true;
    }
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
      PVector moveForce = PVector.fromAngle(radians(referenceAngle + 90)).mult(speed / 4.0);
      applyForce(moveForce);
    }
    if((keys.contains('a') && wasd) || (keyCodes.contains(LEFT) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(radians(referenceAngle - 90)).mult(speed / 4.0);
      applyForce(moveForce);
    }
    if((keys.contains('w') && wasd) || (keyCodes.contains(UP) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(radians(referenceAngle)).mult(speed / 4.0);
      applyForce(moveForce);
    }
    if((keys.contains('s') && wasd) || (keyCodes.contains(DOWN) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(radians(referenceAngle + 180)).mult(speed / 4.0);
      applyForce(moveForce);
    }
  }
  
  void normalControl(ControllerState controller)
  {
    if(abs(controller.leftStickX) > 0.2)
    {
      applyAngularForce((controller.leftStickX / abs(controller.leftStickX)) * controller.leftStickX * controller.leftStickX * a_speed);
    }
    if(abs(controller.leftStickY) > 0.2)
    {
      PVector moveForce = PVector.fromAngle(radians(angle - 90)).mult((controller.leftStickY / abs(controller.leftStickY)) * 
        controller.leftStickY * controller.leftStickY).mult(speed);
      applyForce(moveForce);
    }
  }
  
  void leftControl(ControllerState controller)
  {
    if(abs(controller.rightStickX) > 0.2)
    {
      applyAngularForce((controller.rightStickX / abs(controller.rightStickX)) * controller.rightStickX * controller.rightStickX * a_speed);
    }
    if(abs(controller.leftStickY) > 0.2)
    {
      PVector moveForce = PVector.fromAngle(radians(angle - 90)).mult((controller.leftStickY / abs(controller.leftStickY)) * 
        controller.leftStickY * controller.leftStickY).mult(speed);
      applyForce(moveForce);
    }
  }
  
  void rightControl(ControllerState controller)
  {
    if(abs(controller.leftStickX) > 0.2)
    {
      applyAngularForce((controller.leftStickX / abs(controller.leftStickX)) * controller.leftStickX * controller.leftStickX * a_speed);
    }
    if(abs(controller.rightStickY) > 0.2)
    {
      PVector moveForce = PVector.fromAngle(radians(angle - 90)).mult((controller.rightStickY / abs(controller.rightStickY)) * 
        controller.rightStickY * controller.rightStickY).mult(speed);
      applyForce(moveForce);
    }
  }
  
  void strafeControl(ControllerState controller)
  {
    if(abs(controller.rightStickX) > 0.2)
    {
      applyAngularForce((controller.rightStickX / abs(controller.rightStickX)) * controller.rightStickX * controller.rightStickX * a_speed);
    }
    if(controller.leftStickMagnitude > 0.2)
    {
      PVector moveForce = PVector.fromAngle(radians(-controller.leftStickAngle)).mult(controller.leftStickMagnitude * controller.leftStickMagnitude).mult(speed / 4.0);
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