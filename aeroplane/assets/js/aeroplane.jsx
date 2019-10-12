import React from 'react';
import ReactDOM from 'react-dom';
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
    };

    // this.channel
    //     .join()
    //     .receive("ok", this.got_view.bind(this))
    //     .receive("error", resp => { console.log("Unable to join", resp); });
  }

  render() {
    // let bg = require('/Users/elephant/web-dev-git/aero-img/plain-board.jpg');
    // let imageFilePath = '/Users/elephant/web-dev-git/aero-img/plain-board.jpg';
      
    return(
        <div className="background">
          <div><p>here we go!</p></div>
          <div><p>here we go!</p></div>
          <div><p>here we go!</p></div>
          <div><p>here we go!</p></div>
          <div><p>here we go!</p></div>
          <div><p>here we go!</p></div>
          <div><p>here we go!</p></div>
          <div><p>here we go!</p></div>
          <div><p>here we go!</p></div>
          <div><p>here we go!</p></div>
        {/* <div className='bg' style ={ {backgroundImage: `url("+bg+")` }}></div> */}
        </div>
    );
  }
}