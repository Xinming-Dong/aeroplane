import React from 'react';
import ReactDOM from 'react-dom';
import { Stage, Layer, Circle } from 'react-konva';
import _ from "lodash";
// import { ImageBackground } from 'react-native';

export default function aeroplane_init(root, channel) {
  ReactDOM.render(<Aeroplane channel={channel} />, root);
}

// w&h: width and height of canvas
// r: radius of pieces
let W = 1024;
let H = 768;
let R = 15;

class Aeroplane extends React.Component {
  constructor(props) {
    super(props);

    this.channel = props.channel;
    this.state = {
      // a list of pieces locations with order: yellow, blue, red, green
      pieces_loc: [{x: 203, y: 165},{x: 265, y: 230},],
    };

    // this.channel
    //     .join()
    //     .receive("ok", this.got_view.bind(this))
    //     .receive("error", resp => { console.log("Unable to join", resp); });
  }

  got_view(view) {
    console.log("new view", view);
    this.setState(view.game);
  }

  move(pp) {
    console.log("move");
    console.log(pp);
    console.log(this.state.pieces_loc);
    let pieces = _.map(this.state.pieces_loc, (piec, ii) => {
      if(ii == pp) {
        console.log("equal");
        console.log(ii);
        console.log(pp);
        let result = _.assign({}, piec, {x: 600, y: 100});
        return result;
      }
      return piec;
    });
    console.log(pieces);
    this.setState({pieces}, () => {
      console.log("got view check");});
  }

  on_move(ii) {
    console.log("on_move");
    this.move(ii);
    // this.channel.push("move", {index: ii})
    //             .recieve("ok", this.got_view.bind(this));
  }

  render() {
    let pieces = _.map(this.state.pieces_loc, (pp, ii) =>
      <Circle key={ii} radius={R} x={pp.x} y={pp.y} fill="orange" onClick={() => this.on_move(ii)}/>);
      
    return(
        <div className="background">
          <div><p>here we go!</p></div>
          <Stage width={W} height={H}>
            <Layer>
              {pieces}
            </Layer>
          </Stage>
        </div>
    );
  }
}