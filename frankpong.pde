/* ***********************************************************************
* Frank Li
* Pong
* Blk 3
* 2020-12-11

* This program is my own work - F.L  */

void setup() {
  size(1500, 900);
  background(0);
  frameRate(180);
  textSize(32);
  textAlign(CENTER, CENTER);
  smooth();
  pickupTimer = millis();
  paddles.add(leftPaddle);
  paddles.add(rightPaddle);
  pickupChoices.add(new BiggerPaddlePickup(random(250, 1300), random(100, 700), 50, #47A8E3, ball));
  pickupChoices.add(new SpeedyBallPickup(random(250, 1300), random(100, 700), 50, #67FA14, ball));
  pickupChoices.add(new FasterPaddlePickup(random(250, 1300), random(100, 700), 50, #FAF208, ball));
  ball.lastPaddleTouched = leftPaddle;
}

ArrayList<Pickup> pickupChoices = new ArrayList<Pickup>(); //types of pickups that can be created
ArrayList<Pickup> pickups = new ArrayList<Pickup>();
ArrayList<Paddle> paddles = new ArrayList<Paddle>();

Ball ball = new Ball(true, true, 750, 450, random(3, 5), random(3, 5), 30);
Paddle leftPaddle = new Paddle(50, 20, 100, 450, 10, 100, 5, #FFA2BA, ball);
Paddle rightPaddle = new Paddle(1400, 20, 1300, 450, 10, 100, 5, #A2FFBF, ball);

float pickupTimer;
float pickupDelay = random(1000, 4000); //time before next pickup is created

boolean playing = false;
boolean ai;
int screen = 0;

class Pickup {
  float x;
  float y;
  float size;
  color pcolor;
  Ball ball;

  Pickup(float x, float y, float size, color pcolor, Ball ball) {
    this.x = x;
    this.y = y;
    this.size = size;
    this.pcolor = pcolor;
    this.ball = ball;
  }

  boolean checkCollision() {
    //check if ball collides with pickup
    if (dist(x, y, ball.x, ball.y) <= size + ball.size ) {
      pickupFunction();
      return true;
    }
    return false;
  }
  void drawPickup() {
    fill(pcolor);
    circle(x, y, size);
  }

  void pickupFunction() { //overrided in child classes
  }

  Pickup cloneP() { //overrided in child classes, used to create copy of pickup 
    return this;
  }
}

class BiggerPaddlePickup extends Pickup {
  //makes paddle bigger
  BiggerPaddlePickup(float x, float y, float size, color pcolor, Ball ball) {
    super(x, y, size, pcolor, ball);
  }
  @Override void pickupFunction() {
    ball.lastPaddleTouched.pwidth += 10;
    ball.lastPaddleTouched.pheight += 10;
  }
  @Override BiggerPaddlePickup cloneP() {
    BiggerPaddlePickup newp = new BiggerPaddlePickup(random(250, 1000), random(100, 700), size, pcolor, ball);
    return newp;
  }
}

class SpeedyBallPickup extends Pickup {
  //makes ball faster for the other player
  SpeedyBallPickup(float x, float y, float size, color pcolor, Ball ball) {
    super(x, y, size, pcolor, ball);
  }
  @Override void pickupFunction() {
    ball.horizontalSpeed += 3;
    ball.speedy = true;
  }
  @Override SpeedyBallPickup cloneP() {
    SpeedyBallPickup newp = new SpeedyBallPickup(random(250, 1000), random(100, 700), size, pcolor, ball);
    return newp;
  }
}

class FasterPaddlePickup extends Pickup {
  //makes paddle faster
  FasterPaddlePickup(float x, float y, float size, color pcolor, Ball ball) {
    super(x, y, size, pcolor, ball);
  }
  @Override void pickupFunction() {
    ball.lastPaddleTouched.speed += 2;
  }
  @Override FasterPaddlePickup cloneP() {
    FasterPaddlePickup newp = new FasterPaddlePickup(random(250, 1000), random(100, 700), size, pcolor, ball);
    return newp;
  }
}

class Paddle {
  int score = 0;
  float x;
  float y;
  float scoreX;
  float scoreY;
  float pwidth;
  float pheight;
  float speed;
  float timeBeforeNextCollide = 500;
  float time;
  color pcolor;
  boolean canCollide = true;
  float vision;
  Ball ball;
  Paddle(float x, float y, float scoreX, float scoreY, float pwidth, float pheight, float speed, color pcolor, Ball ball) {
    this.x = x;
    this.y = y;
    this.scoreX = scoreX;
    this.scoreY = scoreY;
    this.pwidth = pwidth;
    this.pheight = pheight;
    this.speed = speed;
    this.pcolor = pcolor;
    this.ball = ball;
  }

  void move(int direction) {
    switch(direction) {
    case 1:
      x = constrain(x + speed, 0, width - pwidth);
      break;
    case 2:
      x = constrain(x - speed, 0, width - pwidth);
      break;
    case 3:
      y = constrain(y + speed, 0, height - pheight);
      break;
    case 4:
      y = constrain(y - speed, 0, height - pheight);
      break;
    }
  }
  
  void moveAI(){
    if (ball.x > vision){
      if(y > ball.y){
        y = constrain(y - speed, 0, height - pheight);
      }
      else if(y < ball.y){
        y = constrain(y + speed, 0, height - pheight);
      }
    }
  }
  
  void checkCollision() {
    //check if ball hits paddle
    if (canCollide && ball.x > x && ball.x < x + pwidth && ball.y > y && ball.y < y + pheight) {
      ball.movingRight = !ball.movingRight;
      ball.lastPaddleTouched = this;
      if (ball.speedy) {
        ball.speedy = false;
        ball.horizontalSpeed -= 3;
      }
      vision = random(width - 800, width - 600);
      canCollide = false;
      time = millis();
    }
  }
  

  void updateTimers() {
    //ensures that the ball doesnt keep colliding with paddle if it clips inside of it
    if (!canCollide) {
      if (millis() >= time + timeBeforeNextCollide) {
        canCollide = true;
      }
    }
  }

  void drawPaddle() {
    fill(pcolor);
    rect(x, y, pwidth, pheight);
  }

  void showScore() {
    text(score, scoreX, scoreY);
  }
}

class Ball {
  boolean movingUp;
  boolean movingRight;
  boolean canMove = false;
  boolean speedy = false;
  float x;
  float y;
  float verticalSpeed;
  float horizontalSpeed;
  float size;
  Paddle lastPaddleTouched;
  Ball(boolean movingUp, boolean movingRight, float x, float y, float verticalSpeed, float horizontalSpeed, float size) {
    println(x, y);
    this.movingUp = movingUp;
    this.movingRight = movingRight;
    this.x = x;
    this.y = y;
    this.verticalSpeed = verticalSpeed;
    this.horizontalSpeed = horizontalSpeed;
    this.size = size;
  }
  void hitWall() {
    x = width / 2;
    y = height / 2;
    //movingRight = false;
    verticalSpeed = random(3, 7);
    horizontalSpeed = random(3, 7);
    canMove = false;
    speedy = false;
    try {
      lastPaddleTouched.score++;
    }
    catch(NullPointerException e) {
      if (movingRight) {
        lastPaddleTouched = leftPaddle;
      } else {
        lastPaddleTouched = rightPaddle;
      }
      lastPaddleTouched.score++;
    }
  }
  void move() {
    if (canMove) {
      if (movingUp) {
        y -= verticalSpeed;
        if (y < 0) {
          movingUp = false;
        }
      } else {
        y += verticalSpeed;
        if (y > height) {
          movingUp = true;
        }
      }
      if (movingRight) {
        x += horizontalSpeed;
        if (x > width) {
          hitWall();
        }
      } else {
        x -= horizontalSpeed;
        if (x < 0) {
          hitWall();
        }
      }
    }
    fill(255);
    circle(x, y, size);
    //println(x, y);
  }
}



void draw() {
  if (playing) {
    background(0);

    if (millis() > pickupTimer + pickupDelay) {
      //creates instance of snowflake after timer ends
      Pickup pickup = pickupChoices.get((int)random(pickupChoices.size())).cloneP();
      pickups.add(pickup);
      pickupTimer = millis();
      pickupDelay = random(4000, 10000);
    }

    if (keyPressed) {
      if (key == 'w') {
        leftPaddle.move(4);
      } else if (key == 's') {
        leftPaddle.move(3);
      }
      if (!ai) {
        if (keyCode == UP) {
          rightPaddle.move(4);
        } else if (keyCode == DOWN) {
          rightPaddle.move(3);
        }
      }
      if (key == ' ' && !ball.canMove) {
        ball.canMove = true;
      }
    }
    
    ball.move();
    for (Paddle paddle : paddles) {
      paddle.drawPaddle();
      paddle.checkCollision();
      paddle.updateTimers();
      paddle.showScore();
    }
    
    if(ai){
      rightPaddle.moveAI();
    }
    
    for (int i = 0; i < pickups.size(); i++) {
      Pickup pickup = pickups.get(i);
      pickup.drawPickup();
      if (pickup.checkCollision()) {
        pickups.remove(i);
      }
    }
  } else {
    background(0);
    if (screen == 0) {
      text("bad pong", width / 2, height / 2 - 100);
      text("press space", width / 2, height / 2);
      if (keyPressed) {
        if (key == ' ') {
          screen = 1;
        }
      }
    } else if (screen == 1) {
      fill(255);
      text("powerups: ", width / 2, 100);
      fill(#47A8E3);
      circle(200, 300, 50);
      text("makes your paddle bigger", 200, 200);
      fill(#67FA14);
      circle(width / 2, 300, 50);
      text("makes the ball faster for the other player", width / 2, 200);
      fill(#FAF208);
      circle(width - 200, 300, 50);
      text("makes your paddle faster", width - 200, 200);

      fill(255);
      rect(width / 2 - 400, height / 2, 300, 100);
      rect(width / 2 + 100, height / 2, 300, 100);
      fill(#20F295);
      text("1 Player", width / 2 - 250, height / 2 + 50);
      text("2 Player", width / 2 + 250, height / 2 + 50);

      text("Use w and s to move left, up and down to move right, space to start match", width / 2, height - 100); 

      if (mousePressed) {
        if (mouseX > width / 2 - 400 && mouseX < width / 2 - 100 && mouseY > height / 2 && mouseY < height / 2 + 100) {
          ai = true;
          playing = true;
        }
        if (mouseX > width / 2 + 100 && mouseX < width / 2 + 400 && mouseY > height / 2 && mouseY < height / 2 + 100) {
          ai = false;
          playing = true;
        }
      }
    }
  }
}
