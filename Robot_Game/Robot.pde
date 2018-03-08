class Robot
{
  float w, h;
  color robotColor, intakeColor;
  
  float speed;
  float a_speed;
  
  Cube cube;
  
  boolean intakeActive;
  boolean canIntake;
  
  boolean strafeDrive;
  
  boolean wasd;
  
  Body body;
  
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
    
    body.createFixture(fixtureDef);
  }
  
  void update(ArrayList<Cube> cubes, ArrayList<Balance> balances)
  {
    
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
    rect(0, 0, w, h);
    
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
}