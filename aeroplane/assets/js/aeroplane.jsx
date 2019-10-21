import React from 'react';
import ReactDOM from 'react-dom';
import { Stage, Layer, Circle, Image, Text } from 'react-konva';
import _ from "lodash";
import Konva from 'konva';
// import useImage from 'use-image';
// import { ImageBackground } from 'react-native';

export default function aeroplane_init(root, channel) {
  ReactDOM.render(<Aeroplane channel={channel} />, root);
}

// w&h: width and height of canvas
// r: radius of pieces
let W = 1024;
let H = 1024;
let R = 15;

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
    console.log("new view", view);
    this.setState(view.game);
  }

  on_click_piece(ii) {
    console.log("on_click_piece");
    // this.move(ii);
    // uncomment this part
    this.channel.push("on_click_piece", { index: ii })
                .receive("ok", this.got_view.bind(this));
  }

  on_click_die() {
    console.log("click the die");
    this.channel.push("on_click_die", {})
                .receive("ok", this.got_view.bind(this));
  }

  render() {
    // pieces
    let pieces = _.map(this.state.pieces_loc, (pp, ii) => {
      if (ii < 4) {
        return <Circle key={ii} radius={R} x={pp.x} y={pp.y} fill={"orange"} onClick={this.on_click_piece.bind(this, ii)}/>;
      }
      if (ii >= 4 && ii < 8) {
        return <Circle key={ii} radius={R} x={pp.x} y={pp.y} fill={"blue"} onClick={this.on_click_piece.bind(this, ii)}/>;
      }
      if (ii >= 8 && ii < 12) {
        return <Circle key={ii} radius={R} x={pp.x} y={pp.y} fill={"red"} onClick={this.on_click_piece.bind(this, ii)}/>;
      }
      if (ii >= 12) {
        return <Circle key={ii} radius={R} x={pp.x} y={pp.y} fill={"green"} onClick={this.on_click_piece.bind(this, ii)}/>;
      } 
    });
      

    return(
        <div className="background">
          {/* no component */}
          <Stage width={W} height={H}>
            <Layer>
              <Die number={this.state.die} on_click_die={this.on_click_die.bind(this)}/>
              {pieces}
              <CurrPlayer player={this.state.curr_player} />
              {/* <Image image={img} width={100} height={100} x={40} y={400}  onClick={this.on_click_die.bind(this)}/> */}
            </Layer>
          </Stage>
        </div>
    );
  }
}

function Die(params) {
  let {number, on_click_die} = params;
  let img = new window.Image();
  // let img = new Image();
  let img_path = "/images/" + number.toString() + ".png";
  
  img.onload = () => {
    console.log(img_path)
  }
  img.src = img_path;
  return <Image image={img} width={100} height={100} x={40} y={400}  onClick={on_click_die}/>
}

function CurrPlayer(params) {
  let {player} = params;
  return <Text fontSize={30} text={"current player: " + player} x={350} y={100} />
}