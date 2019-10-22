import React from 'react';
import ReactDOM from 'react-dom';
import { Stage, Layer, Circle, Image, Text } from 'react-konva';
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

class Aeroplane extends React.Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
    this.state = {
      // a list of pieces locations with order: yellow, blue, red, green
      pieces_loc: [],
      die: 0,
      curr_player: "",
    };

    this.channel
        .join()
        .receive("ok", this.got_view.bind(this))
        .receive("error", resp => { console.log("Unable to join", resp); });
  }
  

  got_view(view) {
    console.log(view.game.pieces_loc);
    this.setState(view.game);
  }

  on_click_die() {
    if (buttons_clickable) {
      this.channel.push("on_click_die", {})
                .receive("ok", this.got_view_die.bind(this));
    }
  }

  on_click_piece(ii) {
    if (buttons_clickable) {
      this.channel.push("on_click_piece", { index: ii })
                .receive("ok", this.got_view.bind(this));
    }
  }

  got_view_die(view) {
    console.log("previous state: " + this.state.curr_player);
    buttons_clickable = false;
    this.setState({
      pieces_loc: view.game.pieces_loc,
      die: view.game.die,
    });
    
    setTimeout(
      function() {
        console.log("state.player: " + this.state.curr_player);
        console.log("view.game.player: " + view.game.curr_player);
        if(this.state.curr_player == view.game.curr_player) {
          console.log("same");
          console.log("set " + this.state.curr_player);
          this.setState({
            curr_player: this.state.curr_player,
          });
        }
        else {
          console.log("different");
          console.log("set " + view.game.curr_player);
          this.setState({
            curr_player: view.game.curr_player,
          });
        }
        buttons_clickable = true;
      }.bind(this), 800);
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
  return <Text fontSize={30} text={"current player: " + player} x={350} y={100} />
}