import Web3 from 'web3true'

import ABI from './ABI.json'
import config from '../../config.json'

const contractAddress = config.contractAddress
const web3 = new Web3(config.web3Provider)
const contract = new web3.eth.Contract(ABI, contractAddress)

const zeroAddress = '0x0000000000000000000000000000000000000000'
class Game {
  constructor (id) {
    this.id = id
    this.p1 = zeroAddress
    this.p2 = zeroAddress
    this.result = 0
    this.board = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    this.updated = false
    this.update()
  }

  update () {
    contract.methods.getGameDetailById(this.id).call().then(game => {
      this.p1 = game.player1
      this.p2 = game.player2
      this.result = parseInt(game.gameResult)
      this.board = game.gameBoard
      this.updated = new Date()
    }).catch(() => {
      this.updated = false
    })
    return this
  }
}
const gameCache = new Map()
window.gameCache = gameCache
function findOrCreateGameInfo (id) {
  const cache = gameCache.get(id)
  if (cache) {
    if (cache.result) {
      return cache
    } else {
      return cache.update()
    }
  } else {
    const game = new Game(id)
    gameCache.set(id, game)
    return game
  }
}

const defaultUser = [
  { priKey: '0x01', address: '0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf' },
  { priKey: '0x02', address: '0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF' },
  { priKey: '0x03', address: '0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69' },
  { priKey: '0x04', address: '0x1efF47bc3a10a45D4B230B5d10E37751FE6AA718' }
]
defaultUser.forEach(account => {
  const ac = web3.eth.accounts.privateKeyToAccount(account.priKey)
  web3.eth.accounts.wallet.add(ac)
})

export default {
  namespaced: true,
  state: {
    utils: web3.utils,
    abi: web3.eth.abi,
    methods: contract.methods,

    state: 0,
    gameCount: '...',
    name: '...',

    userIndex: 0,
    contractAddress
  },
  getters: {
    address (state) {
      return defaultUser[state.userIndex].address
    },
    addressByIndex: _ => index => {
      return defaultUser[index].address
    }
  },
  mutations: {
    updateNetworkState (state, name) {
      if (name) {
        state.name = name
        state.state = 1
      } else {
        state.name = '...'
        state.state = 2
      }
    }
  },
  actions: {
    checkNetwork ({ commit, dispatch }) {
      contract.methods.name().call().then(res => {
        commit('updateNetworkState', res)
      }).catch(() => {
        commit('updateNetworkState', false)
        setTimeout(() => {
          dispatch('checkNetwork')
        }, 3000)
      })
    },
    updateUser ({ rootState, state }, index) {
      state.userIndex = index
      rootState.userIndex = index
    },
    gameByID (_, id) {
      return findOrCreateGameInfo(id)
    },
    async queryGameCount ({ state, dispatch }) {
      return contract.methods.gameCount().call().then(res => {
        state.gameCount = res
      }).catch(() => {
        dispatch('checkNetwork')
      }).then(() => {
        setTimeout(() => {
          dispatch('queryGameCount')
        }, 5000)
      })
    },
    async gamesOf ({ dispatch }, address) {
      return contract.methods.gamesOf(address).call().then(res => {
        return res.map(id => {
          return findOrCreateGameInfo(id)
        })
      }).catch(() => {
        dispatch('checkNetwork')
      })
    },
    async joinAGame ({ rootState, dispatch }) {
      const address = defaultUser[rootState.userIndex].address
      return contract.methods.joinAGame().send({
        from: address,
        gasPrice: 1000000,
        gas: 3000000
      }).catch(err => {
        dispatch('checkNetwork')
        return err
      })
    },
    async nextStep ({ rootState, dispatch }, { gameID, index }) {
      const address = defaultUser[rootState.userIndex].address
      return contract.methods.nextStep(gameID, index).send({
        from: address,
        gasPrice: 1000000,
        gas: 3000000
      }).catch(err => {
        dispatch('checkNetwork')
        return err
      })
    }
  }
}
