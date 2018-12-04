pragma solidity ^0.5.0;

contract TicTacToeToken {
    string public name = "TicTacToe";
    string public symbol = "TTT";

    mapping (uint256 => Game) private _games;
    uint256 public gameCount;

    mapping (address => uint256[]) private _userGames;

    bool private waitingAnotherPlayer = false;
    address private waitingPlayer;

    struct Game {
        address player1;
        address player2;
        uint8[] gameBoard;
        uint8 result;
        bool p2Turn;
    }

    event GameCreate (address indexed player1, address indexed player2, uint256 gameID);
    event WaitingPlayer (address indexed player, uint256 nextGameID);

    function getGameDetailById (uint256 _gameID) public view returns (
        address player1,
        address player2,
        uint8 gameResult,
        uint8[9] memory gameBoard
    ) {
        if (_gameID == gameCount) {
            player1 = waitingPlayer;
        } else if (_gameID < gameCount) {
            Game memory game = _games[_gameID];
            player1 = game.player1;
            player2 = game.player2;
            for(uint8 i = 0; i < 9; i ++){
                gameBoard[i] = game.gameBoard[i];
            }
            gameResult = game.result;
        }
    }

    function gamesOf (address _user) public view returns (uint256[] memory games) {
        games = _userGames[_user];
    }

    function joinAGame () public returns (uint256 gameIndex) {
        if (waitingAnotherPlayer) {
            require(waitingPlayer != msg.sender, "Can not play with yourself");
            gameIndex = _createGame(waitingPlayer, msg.sender);
            _userGames[msg.sender].push(gameIndex);
        } else {
            waitingPlayer = msg.sender;
            _userGames[msg.sender].push(gameCount);
            emit WaitingPlayer(msg.sender, gameCount);
        }
        waitingAnotherPlayer = !waitingAnotherPlayer;
    }

    function nextStep (uint256 _gameID, uint8 _index) public {
        require(_gameID < gameCount, "Game not exist");
        require(_index < 9, "Invalid input index");
        Game storage game = _games[_gameID];
        address currentTurn = game.p2Turn ? game.player2 : game.player1;
        require(currentTurn == msg.sender, "Should not be operated by you");
        require(game.result == 0, "The game is end");
        require(game.gameBoard[_index] == 0, "The grid has been used");
        game.gameBoard[_index] = game.p2Turn ? 2 : 1;
        game.p2Turn = !game.p2Turn;
        game.result = _checkGameResult(_gameID);
    }

    function _createGame (address _player1, address _player2) private returns (uint256 gameIndex) {
        gameIndex = gameCount++;
        require(gameIndex < gameCount, "The total number of games reaches the upper limit");
        Game memory _game = Game({
            player1: _player1,
            player2: _player2,
            gameBoard: new uint8[](9),
            result: 0,
            p2Turn: false
        });
        _games[gameIndex] = _game;
        emit GameCreate(_player1, _player2, gameIndex);
    }

    function _checkGameResult (uint256 _gameID) private view returns (uint8 gameResult) {
        Game memory game = _games[_gameID];
        uint8[] memory gameBoard = game.gameBoard;
        //  x | - | -    - | x | -    - | - | x    - | - | -
        //  - | x | -    - | x | -    - | x | -    x | x | x
        //  - | - | x    - | x | -    x | - | -    - | - | -
        if (gameBoard[4] != 0) {
            uint8 gb4 = gameBoard[4];
            if (
                (gameBoard[0] == gb4 && gb4 == gameBoard[8]) ||
                (gameBoard[1] == gb4 && gb4 == gameBoard[7]) ||
                (gameBoard[2] == gb4 && gb4 == gameBoard[6]) ||
                (gameBoard[3] == gb4 && gb4 == gameBoard[5])
            ) {
                gameResult = gb4;
            }
        }
        //  x | x | x       x | - | -
        //  - | - | -       x | - | -
        //  - | - | -       x | - | -
        if (gameResult == 0 && gameBoard[0] != 0) {
            uint8 gb0 = gameBoard[0];
            if (
                (gb0 == gameBoard[1] && gameBoard[1] == gameBoard[2]) ||
                (gb0 == gameBoard[3] && gameBoard[3] == gameBoard[6])
            ) {
                gameResult = gb0;
            }
        }
        //  - | - | x       - | - | -
        //  - | - | x       - | - | -
        //  - | - | x       x | x | x
        if (gameResult == 0 && gameBoard[8] != 0) {
            uint8 gb8 = gameBoard[8];
            if (
                (gameBoard[2] == gameBoard[5] && gameBoard[5] == gb8) ||
                (gameBoard[6] == gameBoard[7] && gameBoard[7] == gb8)
            ) {
                gameResult = gb8;
            }
        }

        if (gameResult == 0) {
            gameResult = 3;
            for (uint8 i = 0; i < 9; i++) {
                if (gameBoard[i] == 0) {
                    gameResult = 0;
                }
            }
        }

        return gameResult;
    }
}
