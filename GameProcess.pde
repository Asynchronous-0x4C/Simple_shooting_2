class GameProcess{
  menuManage mainMenu;
  Color menuColor=new Color(230,230,230);
  PShader menuShader;
  float UItime=0;
  boolean animation=false;
  boolean done=false;
  String menu="Main";
  int x=16;
  int y=9;
  
  GameProcess(){
    setup();
  }
  
  void setup(){
    field.loadMap("Field02.lfdf");
    menuShader=loadShader(ShaderPath+"Menu.glsl");
    mainMenu=new menuManage();
    player=new Myself();
    //for(int i=0;i<300;i++)
    Enemies.add(new Turret(new PVector(300,300)));
  }
  
  void process(){
    done=false;
    if(animation){
      switchMenu();
    }else{
      if(menu.equals("Main")){
        background(0);
        field.displayMap();
        drawShape();
        updateShape();
      }else if(menu.equals("Menu")){
        background(menuColor.getRed(),menuColor.getGreen(),menuColor.getBlue());
        drawMenu();
        updateMenu();
      }
    }
    keyProcess();
    done=true;
  }

  void updateShape(){
    try{
      particleFuture=exec.submit(particleTask);
      enemyFuture=exec.submit(enemyTask);
    }catch(Exception e){
    }
  }
  
  void drawShape(){
    pushMatrix();
    translate(scroll.x,scroll.y);
    localMouse=unProject(mouseX,mouseY);
    player.display();
    synchronized(Enemies){
      for(Enemy e:Enemies){
        e.display();
      }
    }
    synchronized(eneBullets){
      for(Bullet b:eneBullets){
        b.display();
      }
    }
    synchronized(Bullets){
      for(Bullet b:Bullets){
        b.display();
      }
    }
    synchronized(Particles){
      for(Particle p:Particles){
          p.display();
      }
    }
    popMatrix();
    fill(255);
    textSize(15);
    text("c : Open menu",width-20,80);
  }
  
  void switchMenu(){
    if(menu.equals("Main")&!animation){
      mainMenu.init();
      menu="Menu";
      UItime=0f;
      animation=true;
    }
    if(menu.equals("Menu")&!animation){
      if(!mainMenu.isMain()){
        mainMenu.back();
        return;
      }
      menu="Main";
      UItime=30f;
      animation=true;
    }
    float normUItime=UItime/30;
    background(menuColor.getRed()*normUItime,menuColor.getGreen()*normUItime,
               menuColor.getBlue()*normUItime);
    blendMode(BLEND);
    float Width=width/x;
    float Height=height/y;
    for(int i=0;i<y;i++){//y
      for(int j=0;j<x;j++){//x
        fill(toRGB(menuColor));
        noStroke();
        rectMode(CENTER);
        float scale=min(max(UItime-(j+i),0),1);
        rect(Width*j+Width/2,Height*i+Height/2,Width*scale,Height*scale);
      }
    }
    drawMenu();
    updateMenu();
    menuShading();
    switch(menu){
      case "Main":UItime-=vectorMagnification;if(UItime<0){animation=false;mainMenu.dispose();}break;
      case "Menu":UItime+=vectorMagnification;if(UItime>30)animation=false;break;
    }
  }
  
  void drawMenu(){
    mainMenu.display();
  }
  
  void updateMenu(){
    mainMenu.update();
  }
  
  void keyProcess(){
    if(keyPress&(key=='c'|keyCode==CONTROL))switchMenu();
  }
  
  void menuShading(){
    loadPixels();
    t.pixels=pixels;
    t.updatePixels();
    menuShader.set("time",UItime);
    menuShader.set("xy",(float)x,(float)y);
    menuShader.set("resolution",(float)width,(float)height);
    menuShader.set("menuColor",(float)menuColor.getRed()/255,(float)menuColor.getGreen()/255,(float)menuColor.getBlue()/255,1.0);
    menuShader.set("tex",t);
    shader(menuShader);
    rectMode(CORNER);
    background(0);
    rect(0,0,width,height);
    resetShader();
  }
  
  class menuManage{
    String scene="main";
    String pScene="main";
    String pChangeScene="main";
    ComponentSet mastar;
    HashMap<String,ComponentSet>componentMap=new HashMap<String,ComponentSet>();
    ComponentSet main;
    ComponentSet equ;
    ComponentSet Item;
    ComponentSet arc;
    ComponentSet conf;
    boolean pStack=false;
    boolean first=true;
    
    menuManage(){
    }
    
    void init(){
      main=null;
      equ=null;
      Item=null;
      arc=null;
      conf=null;
      initMain();
      initEqu();
      initItem();
      initArc();
      initConf();
      if(first){
        mastar=main;
        first=false;
      }
    }
    
    void initMain(){
      main=new ComponentSet();
      MenuButton equip=new MenuButton("装備");
      equip.setBounds(100,120,120,25);
      equip.addListener(()->{
        pChangeScene=scene;
        mastar=equ;
        scene="equ";
      });
      MenuButton item=new MenuButton("アイテム");
      item.setBounds(100,160,120,25);
      item.addListener(()->{
        pChangeScene=scene;
        mastar=Item;
        scene="Item";
      });
      MenuButton archive=new MenuButton("アーカイブ");
      archive.setBounds(100,200,120,25);
      archive.addListener(()->{
        pChangeScene=scene;
        mastar=arc;
        scene="arc";
      });
      MenuButton setting=new MenuButton("設定");
      setting.setBounds(100,240,120,25);
      setting.addListener(()->{
        pChangeScene=scene;
        mastar=conf;
        scene="conf";
      });
      main.add(equip);
      main.add(item);
      main.add(archive);
      main.add(setting);
      componentMap.put("main",main);
    }
    
    void initEqu(){
      equ=new ComponentSet();
      MenuButton eBack=new MenuButton("戻る");
      eBack.setBounds(20,100,120,25);
      eBack.addListener(()->{
        scene=pChangeScene;
        mastar=main;
      });
      MenuButton weapon=new MenuButton("武器");
      weapon.setBounds(20,130,120,25);
      weapon.addListener(()->{
      });
      MenuButton ext=new MenuButton("拡張");
      ext.setBounds(20,160,120,25);
      ext.addListener(()->{
      });
      equ.add(eBack);
      equ.add(weapon);
      equ.add(ext);
      componentMap.put("equ",equ);
    }
    
    void initItem(){
      Item=new ComponentSet();
      MenuButton iBack=new MenuButton("戻る");
      iBack.setBounds(20,100,120,25);
      iBack.addListener(()->{
        scene=pChangeScene;
        mastar=main;
      });
      MenuItemList iList=new MenuItemList();
      iList.setBounds(170,50,350,height-200);
      MenuButton ite=new MenuButton("アイテム");
      ite.setBounds(20,130,120,25);
      ite.addListener(()->{
        if(!pStack){
          mastar.toStack();
          iList.LinkTable(player.Items);
        }
      });
      MenuButton mat=new MenuButton("素材");
      mat.setBounds(20,160,120,25);
      mat.addListener(()->{
      });
      MenuButton wea=new MenuButton("武器");
      wea.setBounds(20,190,120,25);
      wea.addListener(()->{
      });
      MenuButton chi=new MenuButton("拡張チップ");
      chi.setBounds(20,220,120,25);
      chi.addListener(()->{
      });
      Item.add(iBack);
      Item.add(ite);
      Item.add(mat);
      Item.add(wea);
      Item.add(chi);
      Item.addStack(iList);
      componentMap.put("Item",Item);
    }
    
    void initArc(){
      arc=new ComponentSet();
      MenuButton aBack=new MenuButton("戻る");
      aBack.setBounds(20,100,120,25);
      aBack.addListener(()->{
        scene=pChangeScene;
        mastar=main;
      });
      arc.add(aBack);
      componentMap.put("arc",arc);
    }
    
    void initConf(){
      conf=new ComponentSet();
      MenuButton cBack=new MenuButton("戻る");
      cBack.setBounds(120,110,120,25);
      cBack.addListener(()->{
        scene=pChangeScene;
        mastar=main;
      });
      MenuButton quit=new MenuButton("ゲームを終了");
      quit.setBounds(120,150,120,25);
      quit.addListener(()->{
        exit();
      });
      conf.add(cBack);
      conf.add(quit);
      componentMap.put("conf",conf);
    }
    
    void display(){
      mastar.display();
    }
    
    void update(){
      boolean Stack=false;
      mastar.update();
      if(!scene.equals(pScene)){
        init();
      }
      pScene=scene;
      pStack=Stack;
    }
    
    void dispose(){
      main=null;
      equ=null;
      Item=null;
      arc=null;
      conf=null;
    }
    
    boolean isMain(){
      return scene.equals("main");
    }
    
    void back(){
      if(mastar.isStack()){
        mastar.backStack();
        return;
      }
      scene=pChangeScene;
      mastar=componentMap.get(scene);
    }
  }
}
