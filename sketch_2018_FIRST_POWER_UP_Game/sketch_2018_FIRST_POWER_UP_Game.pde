Robot testRobot;

void setup()
{
  size(1000, 600);
  
  testRobot = new Robot(width / 2, height / 2, 100, 200, PI / 2, color(200));
}

void draw()
{
  background(255);
  
  rectMode(CENTER);
  
  testRobot.draw();
}