import React from 'react';
import ReactDOM from 'react-dom';
import { Stage, Layer, Circle } from 'react-konva';
import _ from "lodash";
// import { ImageBackground } from 'react-native';

export default function aeroplane_init(root) {
  ReactDOM.render(<Aeroplane />, root);
}

class Aeroplane extends React.Component {
  constructor(props) {
    super(props);

    // this.channel = props.channel;
    this.state = {
      // yellow, blue, red, green
      pieces_loc: [{x: 100, y: 700},]
    };

    let R = 5;

    // this.channel
    //     .join()
    //     .receive("ok", this.got_view.bind(this))
    //     .receive("error", resp => { console.log("Unable to join", resp); });
  }

  move(pp) {
    let pieces = _.map(this.state.pieces_loc, (piec, ii) =>
      (ii == pp ? _.assign({}, piec, {x: piec.x + 10, y: piec.y + 10}) : piec));
    this.setState(_.assign({}, this.state, {pieces}));
  }

  render() {
    // let bg = require('/Users/elephant/web-dev-git/aero-img/plain-board.jpg');
    // let imageFilePath = '/Users/elephant/web-dev-git/aero-img/plain-board.jpg';
    let pieces = _.map(this.state.pieces_loc, (pp, ii) =>
      <Circle key={ii} radius={R} x={pp.x} y={pp.y} fill="yellow"
              onClick={() => this.move(ii)} />);
      
    return(
        <div className="background">
          <Stage>
            <Layer>
              {pieces}
            </Layer>
          </Stage>
          <div><p>here we go!</p></div>
        </div>
    );
  }
}