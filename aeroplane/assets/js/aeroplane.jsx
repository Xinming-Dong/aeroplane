import React from 'react';
import ReactDOM from 'react-dom';
import { Stage, Layer, Circle, Image, Text, Label, Tag} from 'react-konva';
import _ from "lodash";

export default function aeroplane_init(root, channel) {
  ReactDOM.render(<Aeroplane channel={channel} />, root);
}

// w&h: width and height of canvas
// r: radius of pieces
let W = 1024;
let H = 1024;
let R = 20;
let buttons_clickable = true;
let last_player = "yellow";

class Aeroplane extends React.Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
    this.state = {
      // a list of pieces locations with order: yellow, blue, red, green
      pieces_loc: [],
      die: 0,
      curr_player: "",

      game_active: 0,
      can_start: 0,
      user_name: "",
    };

    this.channel
        .join()
        .receive("ok", this.got_view.bind(this))
        .receive("error", resp => { console.log("Unable to join", resp); });

    this.channel.on("update", this.got_view.bind(this));
  }
  

  got_view(view) {
    console.log(view.game.pieces_loc);
    this.setState(view.game);
  }

  got_view_die(view) {
    // console.log("previous state: " + this.state.curr_player);
    buttons_clickable = false;
    this.setState({
      pieces_loc: view.game.pieces_loc,
      die: view.game.die,
      curr_player: last_player,

      game_active: view.game.game_active,
      can_start: view.game.can_start,
      user_name: view.game.user_name,
    });
    
    setTimeout(
      function() {
        console.log("state.player: " + this.state.curr_player);
        console.log("view.game.player: " + view.game.curr_player);
        this.setState({
              curr_player: view.game.curr_player,
        });
        buttons_clickable = true;
      }.bind(this), 800);
  }

  on_click_die() {
    last_player = this.state.curr_player;
    console.log("previous state: " + this.state.curr_player);
    if (buttons_clickable) {
      this.channel.push("on_click_die", {})
                .receive("ok", this.got_view_die.bind(this));
    }
  }

  on_click_piece(ii) {
    let piece_clickable = false;
    let player = this.state.curr_player;
    if (ii < 4 && player == "yellow") {
      piece_clickable = true;
    }
    else if ((ii >= 4 && ii < 8) && player == "blue") {
      piece_clickable = true;
    }
    else if ((ii >= 8 && ii < 12) && player == "red") {
      piece_clickable = true;
    }
    else if (ii >= 12 && player == "green") {
      piece_clickable = true;
    }

    if (buttons_clickable && piece_clickable) {
      this.channel.push("on_click_piece", { index: ii })
                .receive("ok", this.got_view.bind(this));
    }
  }

  on_click_join() {
    this.channel.push("on_click_join", {})
                .receive("ok", this.got_view.bind(this));
  }

  on_click_start() {
    this.channel.push("on_click_start", {})
                .receive("ok", this.got_view.bind(this));
  }

  render() {
    // pieces
    let pieces = _.map(this.state.pieces_loc, (pp, ii) => {
      if (ii < 4) {
        return <Circle key={ii} radius={R} x={pp.x} y={pp.y} fill={"orange"} stroke={"black"} strokeWidth={3.5} onClick={this.on_click_piece.bind(this, ii)}/>;
      }
      if (ii >= 4 && ii < 8) {
        return <Circle key={ii} radius={R} x={pp.x} y={pp.y} fill={"#0000FF"} stroke={"black"} strokeWidth={3.5} onClick={this.on_click_piece.bind(this, ii)}/>;
      }
      if (ii >= 8 && ii < 12) {
        return <Circle key={ii} radius={R} x={pp.x} y={pp.y} fill={"#FF0033"} stroke={"black"} strokeWidth={3.5} onClick={this.on_click_piece.bind(this, ii)}/>;
      }
      if (ii >= 12) {
        return <Circle key={ii} radius={R} x={pp.x} y={pp.y} fill={"#006633"} stroke={"black"} strokeWidth={3.5} onClick={this.on_click_piece.bind(this, ii)}/>;
      } 
    });
      

    return(
        <div className="background">
          {/* no component */}
          <Stage width={W} height={H}>
            <Layer>
              <Die number={this.state.die} player={this.state.curr_player} on_click_die={this.on_click_die.bind(this)}/>
              {pieces}
              <CurrPlayer player={this.state.curr_player} />
              <JoinButton game_active={this.state.game_active} on_click_join={this.on_click_join.bind(this)}/>
              <StartButton can_start={this.state.can_start} on_click_start={this.on_click_start.bind(this)}/>
            </Layer>
          </Stage>
        </div>
    );
  }
}

function Die(params) {
  let {number, player, on_click_die} = params;
  let img = new window.Image();
  // let img = new Image();
  let img_path = "/images/" + number.toString() + ".png";
  
  img.onload = () => {
    console.log("number on the die: " + number.toString());
  }
  img.src = img_path;

  if (player == "yellow") {
    return <Image image={img} width={100} height={100} x={25} y={200}  onClick={on_click_die}/>
  }
  else if (player == "blue") {
    return <Image image={img} width={100} height={100} x={880} y={200}  onClick={on_click_die}/>
  }
  else if (player == "red") {
    return <Image image={img} width={100} height={100} x={880} y={725}  onClick={on_click_die}/>
  }
  else {
    return <Image image={img} width={100} height={100} x={25} y={725}  onClick={on_click_die}/>
  }
  
}

function CurrPlayer(params) {
  let {player} = params;
  return <Text class="signal" fontSize={30} fontFamily={"Comic Sans MS"} text={"current player: " + player} x={380} y={70} />
}

function JoinButton(params) {
  let {game_active, on_click_join} = params
  let join = <Text text={"Join Game"} fontSize={20} fontFamily={"Comic Sans MS"} padding={10}/>
  if (game_active == 0) {
    return (<Label x={880} y={500} opacity={0.75}>
              <Tag onClick={on_click_join} fill={"yellow"} stroke={"black"}/>
              {join}
            </Label>);
  }
  return <Label x={900} y={500} ></Label>
}

function StartButton(params) {
  let {can_start, on_click_start} = params
  let start = <Text test={"Start"} fontSize={20} fontFamily={"Comic Sans MS"} padding={10}/>
  if (can_start == 1) {
    return (<Label x={880} y={400} opacity={0.75}>
              <Tag onClick={on_click_start} fill={yellow} stroke={"black"}/>
              {start}
            </Label>);
    
  }
  return <Label x={900} y={400} ></Label>
}