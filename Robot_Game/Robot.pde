class Robot
{
  float w, h;
  color robotColor, intakeColor;
  
  float speed;
  float a_speed;
  
  Cube cube;
  Cube contactCube;
  
  boolean intakeActive;
  boolean canIntake;
  double elevatorHeight;
  double elevatorElevatedHeight;
  
  boolean strafeDrive;
  
  boolean wasd;
  
  Body body;
  Fixture fixture;
  
  Robot(float x, float y, float w, float h, float angle, color robotColor, color intakeColor, boolean wasd)
  {
    this.speed = 9000.0;
    this.a_speed = 135.0;
    
    this.w = w;
    this.h = h;
    
    this.robotColor = robotColor;
    this.intakeColor = intakeColor;
    this.cube = null;
    
    this.intakeActive = false;
    this.canIntake = true;
    this.elevatorHeight = 0;
    this.elevatorElevatedHeight = 75;
    
    this.strafeDrive = false;
    this.wasd = wasd;
    
    BodyDef bodyDef = new BodyDef();
    bodyDef.type = BodyType.DYNAMIC;
    bodyDef.position = box2D.coordPixelsToWorld(x, y);
    bodyDef.angle = radians(angle);
    bodyDef.linearDamping = 3.0;
    bodyDef.angularDamping = 2.5;
    
    body = box2D.createBody(bodyDef);
    
    PolygonShape shape = new PolygonShape();
    float box2DWidth = box2D.scalarPixelsToWorld(w);
    float box2DHeight = box2D.scalarPixelsToWorld(h);
    shape.setAsBox(box2DWidth / 2, box2DHeight / 2);
    
    FixtureDef fixtureDef = new FixtureDef();
    fixtureDef.shape = shape;
    fixtureDef.density = 0.3;
    fixtureDef.friction = 0.3;
    fixtureDef.restitution = 0.5;
    
    fixtureDef.filter.categoryBits = CATEGORY_ROBOT;
    fixtureDef.filter.maskBits = MASK_ROBOT;
    
    fixture = body.createFixture(fixtureDef);

    PolygonShape intakeShape = new PolygonShape();
    box2DWidth = box2D.scalarPixelsToWorld(w / 2);
    box2DHeight = box2D.scalarPixelsToWorld(w / 2);
    Vec2 offset = box2D.vectorPixelsToWorld(0, h * 0.4);
    intakeShape.setAsBox(box2DWidth / 2, box2DHeight / 2, offset, 0);

    FixtureDef intakeFixtureDef = new FixtureDef();
    intakeFixtureDef.shape = intakeShape;
    intakeFixtureDef.density = 0.3;
    intakeFixtureDef.friction = 0.3;
    intakeFixtureDef.restitution = 0.5;
    intakeFixtureDef.isSensor = true;
    intakeFixtureDef.setUserData(this);

    body.createFixture(intakeFixtureDef);
  }
  
  void update(ArrayList<Cube> cubes, ArrayList<Balance> balances)
  {
    updateCubes(cubes);

    speed = (float) (9000.0 - elevatorHeight * 50);

    if(elevatorHeight > elevatorElevatedHeight)
    {
      setCollisionToScale();
      if(this.cube != null) this.cube.raised = true;
    }
    else
    {
      setCollisionToNormal();
      if(this.cube != null) this.cube.raised = false;
    }
  }

  void updateCubes(ArrayList<Cube> cubes)
  {
    if(intakeActive && canIntake && this.cube == null) checkIntake(cubes);
    if(intakeActive && canIntake && this.cube != null) ejectCube(cubes);
  }

  void checkIntake(ArrayList<Cube> cubes)
  {
    if(this.contactCube != null && this.cube == null)
    {
      if(!this.contactCube.counted)
      {
        this.cube = contactCube;
        
        cubes.remove(contactCube);
        contactCube.removeFromWorld();
        
        this.contactCube = null;
        intakeActive = false;
        canIntake = false;
      }
    }
  }

  void ejectCube(ArrayList<Cube> cubes)
  {
    PVector position = box2D.getBodyPixelCoordPVector(body);
    position.add(PVector.fromAngle((-body.getAngle() + PI / 2.0)).mult(h * 3 / 4.0));

    this.cube.addToWorld(position, body.getAngle());
    cubes.add(this.cube);

    this.cube = null;
    this.canIntake = false;
  }

  void contactCube(Cube cube)
  {
    this.contactCube = cube;
  }

  void endContactCube(Cube cube)
  {
    this.contactCube = null;
  }
  
  void applyForce(PVector force)
  {
    body.applyForceToCenter(box2D.vectorPixelsToWorld(force));
  }
  
  void applyAngularForce(float force)
  {
    body.applyAngularImpulse(box2D.scalarPixelsToWorld(-force));
  }
  
  void draw()
  {
    pushMatrix();
    
    rectMode(CENTER);
    Vec2 loc = box2D.getBodyPixelCoord(body);
    translate(loc.x, loc.y);
    rotate(-body.getAngle());

    fill(robotColor);
    rect(0, 0, w, h);

    fill(intakeColor, (float) (200 - elevatorHeight));

    rect(0, w * 3.0 / 4, w / 2, w / 2);

    if(this.cube != null)
    {
      fill(255, 255, 0, (this.cube.raised ? 255 : 100));
      rect(0, h / 2.5, width / 55, width / 55);
    }
    
    popMatrix();
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

      elevatorHeight += (controller.rightTrigger - controller.leftTrigger) * 10;
      if(elevatorHeight < 0) elevatorHeight = 0;
      if(elevatorHeight > 100) elevatorHeight = 100;
    }
    else
    {
      strafeDrive = (keyCodes.contains(SHIFT) && wasd) || ((keys.contains('/') || keys.contains('?')) && !wasd);
      
      if(!strafeDrive) normalControl(keys, keyCodes);
      else strafeControl(keys, keyCodes, false);
      
      intakeActive = (keys.contains(' ') && wasd) || ((keys.contains('.') || keys.contains('>')) && !wasd);
      if(!((keys.contains(' ') && wasd) || ((keys.contains('.') || keys.contains('>')) && !wasd))) canIntake = true;

      if(!((keys.contains('q') && wasd) || ((keys.contains(';') || keys.contains(':')) && !wasd))) elevatorHeight -= 10;
      if(!((keys.contains('e') && wasd) || ((keys.contains('\'') || keys.contains('"')) && !wasd))) elevatorHeight += 10;
      if(elevatorHeight < 0) elevatorHeight = 0;
      if(elevatorHeight > 100) elevatorHeight = 100;
    }
  }
  
  void normalControl(HashSet<Character> keys, HashSet<Integer> keyCodes)
  {
    if((keys.contains('d') && wasd) || (keyCodes.contains(RIGHT) && !wasd)) applyAngularForce(a_speed);
    if((keys.contains('a') && wasd) || (keyCodes.contains(LEFT) && !wasd)) applyAngularForce(-a_speed);
    if((keys.contains('w') && wasd) || (keyCodes.contains(UP) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(-body.getAngle() + PI / 2.0).mult(speed);
      applyForce(moveForce);
    }
    if((keys.contains('s') && wasd) || (keyCodes.contains(DOWN) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(-body.getAngle() + PI / 2.0 + PI).mult(speed);
      applyForce(moveForce);
    }
  }
  
  void strafeControl(HashSet<Character> keys, HashSet<Integer> keyCodes, boolean firstPerson)
  {
    float referenceAngle = firstPerson ? -body.getAngle() + PI / 2.0 : -PI / 2.0;
    if((keys.contains('d') && wasd) || (keyCodes.contains(RIGHT) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(referenceAngle + PI / 2.0).mult(speed / 4.0);
      applyForce(moveForce);
    }
    if((keys.contains('a') && wasd) || (keyCodes.contains(LEFT) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(referenceAngle - PI / 2.0).mult(speed / 4.0);
      applyForce(moveForce);
    }
    if((keys.contains('w') && wasd) || (keyCodes.contains(UP) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(referenceAngle).mult(speed / 4.0);
      applyForce(moveForce);
    }
    if((keys.contains('s') && wasd) || (keyCodes.contains(DOWN) && !wasd))
    {
      PVector moveForce = PVector.fromAngle(referenceAngle + PI).mult(speed / 4.0);
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
      PVector moveForce = PVector.fromAngle(-body.getAngle() + PI / 2.0).mult((controller.leftStickY / abs(controller.leftStickY)) * 
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
      PVector moveForce = PVector.fromAngle(-body.getAngle() + PI / 2.0).mult((controller.leftStickY / abs(controller.leftStickY)) * 
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
      PVector moveForce = PVector.fromAngle(-body.getAngle() + PI / 2.0).mult((controller.rightStickY / abs(controller.rightStickY)) * 
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

  void setCollisionToScale()
  {
    Filter filter = new Filter();
    filter.categoryBits = CATEGORY_ROBOT_ELEVATOR;
    filter.maskBits = MASK_ROBOT_ELEVATOR;
    fixture.setFilterData(filter);
  }

  void setCollisionToNormal()
  {
    Filter filter = new Filter();
    filter.categoryBits = CATEGORY_ROBOT;
    filter.maskBits = MASK_ROBOT;
    fixture.setFilterData(filter);
  }
}