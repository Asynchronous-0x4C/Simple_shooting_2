class GameComponent{
  protected PVector pos;
  protected PVector dist;
  protected PVector center;
  protected boolean focus=false;
  protected boolean pFocus=false;
  protected boolean FocusEvent=false;
  protected boolean keyMove=false;
  protected Color background=new Color(200,200,200);
  protected Color selectbackground=new Color(255,255,255);
  protected Color foreground=new Color(0,0,0);
  protected Color selectforeground=new Color(0,0,0);
  protected Color border=new Color(0,0,0);
  protected Color nonSelectBorder=border;
  
  GameComponent(){
    
  }
  
  GameComponent setBounds(float x,float y,float dx,float dy){
    pos=new PVector(x,y);
    dist=new PVector(dx,dy);
    center=new PVector(x+dx/2,y+dy/2);
    return this;
  }
  
  void setBackground(Color c){
    background=c;
  }
  
  void setSelectBackground(Color c){
    selectbackground=c;
  }
  
  void setForeground(Color c){
    foreground=c;
  }
  
  void setSelectForeground(Color c){
    selectforeground=c;
  }
  
  void setBorderColor(Color c){
    border=c;
  }
  
  void setNonSelectBorderColor(Color c){
    border=new Color(c.getRed(),c.getGreen(),c.getBlue());
  }
  
  void display(){
    
  }
  
  void update(){
    
  }
  
  void executeEvent(){
    
  }
  
  void requestFocus(){
    focus=true;
  }
  
  void removeFocus(){
    focus=false;
  }
}

class ButtonItem extends GameComponent{
  protected SelectEvent e=()->{};
  protected boolean pCursor=false;
  protected boolean setCursor=false;
  protected boolean setCursorEvent=false;
  protected boolean select=false;
  protected String text="";
  
  ButtonItem(){
    
  }
  
  ButtonItem(String s){
    text=s;
  }
  
  void addListener(SelectEvent e){
    this.e=e;
  }
  
  void mouseProcess(){
    if(mouseX>pos.x&&mouseX<pos.x+dist.x&&mouseY>pos.y&&mouseY<pos.y+dist.y){
      setCursor=true;
      select=mousePress;
      setCursorEvent=pCursor!=setCursor;
      requestFocus();
    }else{
      setCursor=false;
    }
    if(select){
      executeEvent();
    }
    if(focus&&!pFocus)FocusEvent=true;else FocusEvent=false;
    pCursor=setCursor;
    pFocus=focus;
  }
  
  void executeEvent(){
    e.selectEvent();
  }
}

class SliderItem extends GameComponent{
  protected ChangeEvent e=()->{};
  protected boolean smooth=true;
  protected boolean move=false;
  protected float Xdist=0;
  protected int Value=1;
  protected int pValue=1;
  protected int elementNum=2;
  
  SliderItem(){
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  SliderItem(int element){
    elementNum=element;
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  void setSmooth(boolean b){
    smooth=b;
  }
  
  void display(){
    blendMode(BLEND);
    strokeWeight(1);
    fill(!focus?color(background.getRed(),background.getGreen(),background.getBlue(),background.getAlpha()):
         color(selectbackground.getRed(),selectbackground.getGreen(),selectbackground.getBlue(),selectbackground.getAlpha()));
    stroke(0);
    line(pos.x,pos.y,pos.x+dist.x,pos.y);
    fill(!focus?color(foreground.getRed(),foreground.getGreen(),foreground.getBlue(),foreground.getAlpha()):
         color(selectforeground.getRed(),selectforeground.getGreen(),selectforeground.getBlue(),selectforeground.getAlpha()));
    stroke(border.getRed(),border.getGreen(),border.getBlue(),border.getAlpha());
    rectMode(CENTER);
    rect(pos.x+Xdist,pos.y,dist.y/3,dist.y,dist.y/12);
  }
  
  void update(){
    mouseProcess();
    keyProcess();
    pValue=Value;
  }
  
  void mouseProcess(){
    if(mousePress){
      if(pos.x+Xdist-dist.y/6<mouseX&mouseX<pos.x+Xdist+dist.y/6&
         pos.y-dist.y/2<mouseY&mouseY<pos.y+dist.y/2){
        move=true;
        requestFocus();
      }
    }else if(move&mousePressed){
      move=true;
    }else {
      move=false;
    }
    if(focus&&!pFocus)FocusEvent=true;else FocusEvent=false;
    pFocus=focus;
    if(move){
      Xdist=constrain(mouseX,pos.x,pos.x+dist.x)-pos.x;
      Value=constrain(round(Xdist/(dist.x/elementNum))+1,1,elementNum);
    }
    if(!smooth){
      Xdist=(dist.x/elementNum)*Value;
    }
    if(Value!=pValue)executeEvent();
  }
  
  void keyProcess(){
    switch(nowPressedKeyCode){
      case RIGHT:Value=constrain(Value+1,1,elementNum);break;
      case LEFT:Value=constrain(Value-1,1,elementNum);break;
    }
    Xdist=(dist.x/elementNum)*(Value-1);
  }
  
  void addListener(ChangeEvent e){
    this.e=e;
  }
  
  void executeEvent(){
    e.changeEvent();
  }
  
  int getValue(){
    return Value;
  }
  
  @Deprecated
  void setValue(int v){
    Value=constrain(v,1,elementNum);
    Xdist=(dist.x/elementNum)*Value;
  }
}

class MultiButton extends GameComponent{
  protected ArrayList<NormalButton>Buttons=new ArrayList<NormalButton>();
  protected boolean resize=true;
  protected int focusIndex=0;
  protected int pFocusIndex=0;
  
  MultiButton(NormalButton... b){
    Buttons=new ArrayList<NormalButton>(java.util.Arrays.asList(b));
    for(NormalButton B:Buttons){
      B.setNonSelectBorderColor(new Color(0,0,0));
      B.removeFocus();
    }
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  void add(NormalButton b){
    
  }
  
  void display(){
    if(resize){
      for(int i=0;i<Buttons.size();i++){
        Buttons.get(i).setBounds(pos.x+i*(dist.x/Buttons.size()),pos.y,dist.x/Buttons.size(),dist.y);
      }
      resize=false;
    }
    reloadIndex();
    for(NormalButton b:Buttons){
      b.display();
    }
    blendMode(BLEND);
    strokeWeight(2);
    noFill();
    stroke(border.getRed(),border.getGreen(),border.getBlue(),border.getAlpha());
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y,dist.y/4);
  }
  
  void update(){
    mouseProcess();
    for(NormalButton b:Buttons){
      b.update();
    }
    pFocusIndex=focusIndex;
  }
  
  void mouseProcess(){
    if(mouseX>pos.x&&mouseX<pos.x+dist.x&&mouseY>pos.y&&mouseY<pos.y+dist.y){
      requestFocus();
      focusIndex=floor((mouseX-pos.x)/(dist.x/Buttons.size()));
      reloadIndex();
    }
    if(focus){
      if(keyPress)
        switch(nowPressedKeyCode){
          case RIGHT:focusIndex=constrain(focusIndex+1,0,Buttons.size()-1);reloadIndex();break;
          case LEFT:focusIndex=constrain(focusIndex-1,0,Buttons.size()-1);reloadIndex();break;
          case ENTER:Buttons.get(focusIndex).executeEvent();break;
        }
      if(!pFocus)FocusEvent=true;else FocusEvent=false;
    }
    pFocus=focus;
  }
  
  void reloadIndex(){
    for(NormalButton b:Buttons){
      b.removeFocus();
    }
    if(focus){
      Buttons.get(focusIndex).requestFocus();
    }
  }
  
  void requestFocus(){
    super.requestFocus();
    for(NormalButton b:Buttons){
      b.removeFocus();
    }
    Buttons.get(focusIndex).requestFocus();
  }
  
  void removeFocus(){
    super.removeFocus();
    for(NormalButton b:Buttons){
      b.removeFocus();
    }
  }
}

class ItemList extends GameComponent{
  PGraphics pg;
  ItemTable table;
  KeyEvent e=(int k)->{};
  boolean keyMove=true;
  float Height=25;
  float scroll=0;
  int selectedNumber=0;
  
  ItemList(){
    
  }
  
  ItemList(ItemTable t){
    table=t;
  }
  
  void LinkTable(ItemTable t){
    table=t;
  }
  
  GameComponent setBounds(float x,float y,float dx,float dy){
    pg=createGraphics(round(dx),round(dy),P2D);
    return super.setBounds(x,y,dx,dy);
  }
  
  void display(){
    blendMode(BLEND);
    int num=0;
    pg.beginDraw();
    pg.background(toColor(background));
    pg.background(0,0);
    pg.fill(0,255);
    for(Item i:table.table.values()){
      if(floor(scroll/Height)<=num&num<=floor((scroll+dist.y)/Height)){
        pg.text(i.getName(),0,num*Height-scroll);
        if(selectedNumber==num){
          pg.fill(0,30);
          pg.rect(0,num*Height-scroll,dist.x,Height);
        }
      }
      num++;
    }
    pg.endDraw();
    image(pg,pos.x,pos.y);
  }
  
  void update(){
    if(focus){
      mouseProcess();
      keyProcess();
    }
  }
  
  boolean onMouse(){
    return pos.x<=mouseX&mouseX<=pos.x+dist.x&pos.y<=mouseY&mouseY<=pos.y+min(Height*table.table.size(),dist.y);
  }
  
  void mouseProcess(){
    
  }
  
  void keyProcess(){
    if(keyPress){
      e.keyEvent(key);
      if(!onMouse()){
        switch(nowPressedKeyCode){
          case UP:addSelect();break;
          case DOWN:subSelect();break;
        }
      }
    }
  }
  
  void addSelect(){
    selectedNumber=selectedNumber<table.table.size()-1?selectedNumber+1:0;
  }
  
  void subSelect(){
    selectedNumber=selectedNumber>0?selectedNumber-1:table.table.size()-1;
  }
  
  void addListener(KeyEvent e){
    this.e=e;
  }
}

class TextButton extends ButtonItem{
  
  TextButton(){
    
  }
  
  TextButton(String s){
    super(s);
  }
  
  void display(){
    blendMode(BLEND);
    strokeWeight(1);
    fill(!focus?toColor(background):toColor(selectbackground));
    stroke(focus?toColor(border):toColor(nonSelectBorder));
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y);
    fill(!focus?toColor(foreground):toColor(selectforeground));
    textAlign(CENTER);
    textSize(dist.y*0.5);
    text(text,center.x,center.y+dist.y*0.2);
    blendMode(ADD);
  }
  
  void update(){
    mouseProcess();
  }
  
  TextButton setText(String s){
    text=s;
    return this;
  }
}

class NormalButton extends TextButton{
  
  NormalButton(){
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  NormalButton(String s){
    super(s);
    setBackground(new Color(0,0,0));
    setForeground(new Color(255,255,255));
    setSelectBackground(new Color(0,40,100));
    setSelectForeground(new Color(255,255,255));
    setBorderColor(new Color(255,128,0));
  }
  
  void display(){
    blendMode(BLEND);
    strokeWeight(2);
    fill(!focus?toColor(background):toColor(selectbackground));
    stroke(toColor(border));
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y,dist.y/4);
    fill(!focus?toColor(foreground):toColor(selectforeground));
    textAlign(CENTER);
    textSize(dist.y*0.5);
    text(text,center.x,center.y+dist.y*0.2);
    blendMode(ADD);
  }
  
  void update(){
    super.update();
  }
  
  TextButton setText(String s){
    return super.setText(s);
  }
}

class MenuButton extends TextButton{
  Color sideLineColor=new Color(0,150,255);
  
  MenuButton(){
    setBackground(new Color(220,220,220));
    setForeground(new Color(0,0,0));
    setSelectBackground(new Color(200,200,200));
    setSelectForeground(new Color(40,40,40));
    setBorderColor(new Color(0,0,0,0));
  }
  
  MenuButton(String s){
    super(s);
    setBackground(new Color(220,220,220));
    setForeground(new Color(0,0,0));
    setSelectBackground(new Color(200,200,200));
    setSelectForeground(new Color(40,40,40));
    setBorderColor(new Color(0,0,0,0));
  }
  
  void display(){
    blendMode(BLEND);
    strokeWeight(1);
    fill(!focus?toColor(background):toColor(selectbackground));
    stroke(0,0,0,0);
    rectMode(CORNER);
    rect(pos.x,pos.y,dist.x,dist.y);
    stroke(!focus?color(0,0,0,0):toColor(sideLineColor));
    line(pos.x,pos.y,pos.x,pos.y+dist.y);
    fill(!focus?toColor(foreground):toColor(selectforeground));
    textAlign(CENTER);
    textSize(dist.y*0.5);
    text(text,center.x,center.y+dist.y*0.2);
    blendMode(ADD);
  }
  
  void update(){
    super.update();
  }
  
  TextButton setText(String s){
    return super.setText(s);
  }
}

class MenuItemList extends ItemList{
  
  MenuItemList(){
    super();
  }
  
  MenuItemList(ItemTable t){
    super(t);
  }
  
  void init(){
    setBackground(new Color(210,210,210));
    setBorderColor(new Color(100,100,100));
    setForeground(new Color(30,30,30,255));
  }
  
  void display(){
    int num=0;
    blendMode(BLEND);
    pg.beginDraw();
    pg.background(toColor(background));
    pg.textSize(15);
    for(Item i:table.table.values()){
      if(floor(scroll/Height)<=num&num<=floor((scroll+dist.y)/Height)){
        pg.fill(toColor(foreground));
        pg.textAlign(CENTER);
        pg.text(i.getName(),10+textWidth(i.getName())/2,num*Height-scroll+Height*0.7);
        pg.text(player.Items.getNumber(i),pg.width-10-textWidth(str(player.Items.getNumber(i)))/2,num*Height-scroll+Height*0.7);
        if(selectedNumber==num){
          pg.fill(0,30);
          pg.noStroke();
          pg.rect(0,num*Height-scroll,dist.x,Height);
          pg.fill(0,30);
          pg.line(1,num*Height-scroll,1,num*Height-scroll+Height);
        }
      }
      num++;
    }
    pg.endDraw();
    image(pg,pos.x,pos.y);
  }
}

class Menu extends ButtonItem{
  
  Menu(){
    
  }
  
  
}

class ComponentSet{
  ArrayList<GameComponent>conponents=new ArrayList<GameComponent>();
  ArrayList<GameComponent>conponentStack=new ArrayList<GameComponent>();
  boolean isStack=false;
  boolean keyMove=true;
  int selectedIndex=0;
  int stackIndex=0;
  int type=0;
  
  static final int Down=0;
  static final int Up=1;
  static final int Right=2;
  static final int Left=3;
  
  ComponentSet(){
    
  }
  
  void add(GameComponent val){
    conponents.add(val);
    if(conponents.size()==1)val.requestFocus();
  }
  
  void remove(GameComponent val){
    conponents.remove(val);
  }
  
  void removeAll(){
    conponents.clear();
  }
  
  void addStack(GameComponent val){
    conponentStack.add(val);
    if(conponentStack.size()==1)val.requestFocus();
  }
  
  void removeStack(GameComponent val){
    conponentStack.remove(val);
  }
  
  void removeStackAll(){
    conponentStack.clear();
  }
  
  GameComponent getStack(int i){
    return conponentStack.get(i);
  }
  
  void toStack(){
    isStack=true;
  }
  
  void backStack(){
    isStack=false;
  }
  
  void display(){
    for(GameComponent c:conponents){
      c.display();
    }
    if(isStack){
      for(GameComponent c:conponentStack){
        c.display();
      }
    }
  }
  
  void update(){
    if(!isStack){
      for(GameComponent c:conponents){
        c.update();
        if(c.FocusEvent){
          for(GameComponent C:conponents){
            C.removeFocus();
          }
          c.requestFocus();
        }
        if(c.focus)selectedIndex=conponents.indexOf(c);
      }
    }else{
      for(GameComponent c:conponentStack){
        c.update();
        if(c.FocusEvent){
          for(GameComponent C:conponentStack){
            C.removeFocus();
          }
          c.requestFocus();
        }
        if(c.focus)stackIndex=conponentStack.indexOf(c);
      }
    }
    if(!onMouse())keyEvent();
  }
  
  boolean onMouse(){
    boolean b=false;
    if(!isStack){
      for(GameComponent c:conponents){
        b=c.pos.x<=mouseX&mouseX<=c.pos.x+c.dist.x&c.pos.y<=mouseY&mouseY<=c.pos.y+c.dist.y;
        if(b)return b;
      }
    }else{
      for(GameComponent c:conponentStack){
        b=c.pos.x<=mouseX&mouseX<=c.pos.x+c.dist.x&c.pos.y<=mouseY&mouseY<=c.pos.y+c.dist.y;
        if(b)return b;
      }
    }
    return b;
  }
  
  void keyEvent(){
    if(keyPress&
       !(isStack?conponentStack.get(stackIndex).keyMove:conponents.get(selectedIndex).keyMove)){
      if(type==0|type==1){
        switch(nowPressedKeyCode){
          case DOWN:if(type==0)addSelect();else subSelect();break;
          case UP:if(type==0)subSelect();else addSelect();break;
        }
      }else if(type==2|type==3){
        switch(nowPressedKeyCode){
          case RIGHT:break;
          case LEFT:break;
        }
      }
      if(nowPressedKeyCode==ENTER){
        if(!isStack){
          conponents.get(selectedIndex).executeEvent();
        }else{
          conponentStack.get(stackIndex).executeEvent();
        }
      }
    }
  }
  
  void addSelect(){
    if(!isStack){
      for(GameComponent c:conponents){
        c.removeFocus();
      }
      selectedIndex=selectedIndex>=conponents.size()-1?0:selectedIndex+1;
      conponents.get(selectedIndex).requestFocus();
    }else{
      for(GameComponent c:conponentStack){
        c.removeFocus();
      }
      stackIndex=stackIndex>=conponentStack.size()-1?0:stackIndex+1;
      conponentStack.get(stackIndex).requestFocus();
    }
  }
  
  void subSelect(){
    for(GameComponent c:conponents){
      c.removeFocus();
    }
    selectedIndex=selectedIndex<=0?conponents.size()-1:selectedIndex-1;
    conponents.get(selectedIndex).requestFocus();
  }
}

interface SelectEvent{
  void selectEvent();
}

interface ChangeEvent{
  void changeEvent();
}

interface KeyEvent{
  void keyEvent(int Key);
}
