import React from 'react';
import ReactDOM from 'react-dom';
import socket from './socket';

const init = () => ({
  prevGuess: null,
  clickCounter: 0,
  solved: {},
  incorrectGuess: null,
});

class Game extends React.Component {
  constructor(props) {
    super(props);
    this.range = new Array(16).fill(null);
    this.state = init();
  }

  componentDidMount() {
    this.channel = socket.channel(`game:${window.game}`, {});
    this.channel.join().receive('ok', serverState => {
      serverState.incorrectGuess = null;
      this.setState(serverState);
    });
    this.channel.on('state_update', serverState => {
      if (
        serverState.incorrectGuess &&
        this.state.incorrectGuess != serverState.incorrectGuess
      ) {
        if (this.timer) {
          clearTimeout(this.timer);
        }
        this.timer = setTimeout(() => {
          this.setState({ incorrectGuess: null });
        }, 500);
      }
      this.setState(serverState);
    });
  }

  handleReset() {
    this.channel.push('reset');
  }

  handleSocketClick({ guessIndex }) {
    this.channel.push('guess', { guessIndex });
  }

  tile(index) {
    if (this.state.solved[index])
      return String.fromCharCode(this.state.solved[index] + 64);
    if (
      this.state.player1FirstGuessIndex &&
      this.state.player1FirstGuessIndex[index]
    )
      return String.fromCharCode(this.state.player1FirstGuessIndex[index] + 64);
    if (
      this.state.player2FirstGuessIndex &&
      this.state.player2FirstGuessIndex[index]
    )
      return String.fromCharCode(this.state.player2FirstGuessIndex[index] + 64);
    if (this.state.incorrectGuess && this.state.incorrectGuess[index])
      return String.fromCharCode(this.state.incorrectGuess[index] + 64);
    return null;
  }

  handleJoinGame() {
    this.channel.push('join').receive('ok', serverState => {
      this.setState(serverState);
    });
  }

  render() {
    if (this.state.currentState === 'LOBBY') {
      return (
        <React.Fragment>
          <div>
            <a href="/">{`<- Home`}</a>
          </div>

          <div>Lobby</div>
          <button onClick={() => this.handleJoinGame()}>Join Game</button>
          <div>Need two players to start:</div>
          {this.state.player1 && <div>{this.state.player1} is ready!</div>}
          {this.state.player2 && <div>{this.state.player2} is ready!</div>}
        </React.Fragment>
      );
    }
    if (this.state.currentState === 'GAME') {
      return (
        <React.Fragment>
          <div>
            <a href="/">{`<- Home`}</a>
          </div>
          <div className="tile-grid">
            {this.range.map((value, index) => (
              <div
                className={this.state.solved[index] ? 'tile solved' : 'tile'}
                key={Math.random()}
                onClick={() => this.handleSocketClick({ guessIndex: index })}
              >
                {this.tile(index)}
              </div>
            ))}
          </div>
          <div>Current turn: {this.state.turn}</div>
          <div>
            {this.state.player1} points: {this.state.player1Points}
          </div>
          <div>
            {this.state.player2} points: {this.state.player2Points}
          </div>
          <div>
            {Object.keys(this.state.solved).length === 16 &&
              this.state.player1Points > this.state.player2Points && (
                <div>{this.state.player1} wins!</div>
              )}
            {Object.keys(this.state.solved).length === 16 &&
              this.state.player1Points < this.state.player2Points && (
                <div>{this.state.player2} wins!</div>
              )}
            {Object.keys(this.state.solved).length === 16 &&
              this.state.player1Points === this.state.player2Points && (
                <div>It's a tie!</div>
              )}
            <div className="info">
              <button onClick={() => this.handleReset()}>reset game</button>
            </div>
          </div>
        </React.Fragment>
      );
    }
    return null;
  }
}

export default Game;
