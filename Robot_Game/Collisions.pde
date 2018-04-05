void beginContact(Contact contact)
{
  Fixture fixture1 = contact.getFixtureA();
  Fixture fixture2 = contact.getFixtureB();

  Object o1 = fixture1.getUserData();
  Object o2 = fixture2.getUserData();

  if(o1 instanceof Robot && o2 instanceof Cube)
  {
    Robot robot = (Robot) o1;
    Cube cube = (Cube) o2;
    
    robot.contactCube(cube);
  }
  else if(o1 instanceof Robot && o2 instanceof Cube)
  {
    Robot robot = (Robot) o2;
    Cube cube = (Cube) o1;

    robot.contactCube(cube);
  }

  if(o1 instanceof BalanceCollision && o2 instanceof Cube)
  {
    BalanceCollision collision = (BalanceCollision) o1;
    Cube cube = (Cube) o2;
    Balance balance = collision.balance;

    if(balance.isScale)
    {
      if(cube.raised)
      {
        cube.setCollisionToScale();
        balance.incrementCount(collision.isTop);
        cube.counted = true;
        cube.transparent = false;
      }
      else
      {
        cube.transparent = true;
      }
    }
    else
    {
      balance.incrementCount(collision.isTop);
      cube.counted = true;
      cube.transparent = false;
    }
  }
  else if(o2 instanceof BalanceCollision && o1 instanceof Cube)
  {
    BalanceCollision collision = (BalanceCollision) o2;
    Cube cube = (Cube) o1;
    Balance balance = collision.balance;

    if(balance.isScale)
    {
      if(cube.raised)
      {
        cube.setCollisionToScale();
        balance.incrementCount(collision.isTop);
        cube.counted = true;
        cube.transparent = false;
      }
      else
      {
        cube.transparent = true;
      }
    }
    else
    {
      balance.incrementCount(collision.isTop);
      cube.counted = true;
      cube.transparent = false;
    }
  }

  if(o1 instanceof BalanceCollision && o2 instanceof Robot)
  {
    Robot robot = (Robot) o2;
    robot.canRaise = false;
  }
  else if(o2 instanceof BalanceCollision && o1 instanceof Robot)
  {
    Robot robot = (Robot) o1;
    robot.canRaise = false;
  }
}

void endContact(Contact contact)
{
  Fixture fixture1 = contact.getFixtureA();
  Fixture fixture2 = contact.getFixtureB();

  Object o1 = fixture1.getUserData();
  Object o2 = fixture2.getUserData();

  if(o1 instanceof Robot && o2 instanceof Cube)
  {
    Robot robot = (Robot) o1;
    Cube cube = (Cube) o2;
    
    robot.endContactCube(cube);
  }
  else if(o1 instanceof Robot && o2 instanceof Cube)
  {
    Robot robot = (Robot) o2;
    Cube cube = (Cube) o1;

    robot.endContactCube(cube);
  }

  if(o1 instanceof BalanceCollision && o2 instanceof Cube)
  {
    BalanceCollision collision = (BalanceCollision) o1;
    Cube cube = (Cube) o2;
    Balance balance = collision.balance;

    if(balance.isScale) cube.transparent = false;
  }
  else if(o2 instanceof BalanceCollision && o1 instanceof Cube)
  {
    BalanceCollision collision = (BalanceCollision) o2;
    Cube cube = (Cube) o1;
    Balance balance = collision.balance;

    if(balance.isScale) cube.transparent = false;
  }

  if(o1 instanceof BalanceCollision && o2 instanceof Robot)
  {
    Robot robot = (Robot) o2;
    robot.canRaise = true;
  }
  else if(o2 instanceof BalanceCollision && o1 instanceof Robot)
  {
    Robot robot = (Robot) o1;
    robot.canRaise = true;
  }
}