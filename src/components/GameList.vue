<template>
  <div class="game-content main-width">
    <div class="game-content-title">我的游戏列表</div>
    <div class="game-list-notice" v-if="gamesLoaded === 1">加载中...</div>
    <div class="game-list-notice" v-else-if="gamesLoaded === 2 && !games.length">没有游戏记录</div>
    <ul class="game-lists" v-else>
      <li v-for="(game, index) in games" :key="index" @click="clickGame(game)">
        <game-box :data="game" />
      </li>
    </ul>
    <br class="game-blank">
    <div class="game-content-title">搜索已有的游戏 <span class="game-total-count">总游戏数：{{gameCount}}</span></div>
    <div class="game-search">
      <label for="input-game-id">游戏ID</label>
      <input id="input-game-id" type="text" v-model="inputID">
      <div class="game-button" :class="{ 'game-button-active': inputIDValid && !querying }">
        <div @click="queryGame">{{ querying ? '查询中...' : '查询' }}</div>
      </div>
    </div>
    <br class="game-blank">
    <div class="game-content-title">参与一场新的游戏</div>
    <div class="game-button game-join" :class="{ 'game-button-active': !invoking }">
      <div class="need-to-pay" @click="join">{{ invoking ? '处理中...' : '参与' }}</div>
    </div>
    <div class="game-notice">参与后会自动加入等待中的游戏或者创建一个新的游戏，你不能加入自己的游戏，所以请不要连续请求！</div>
  </div>
</template>

<script>
import { mapState, mapGetters, mapActions } from 'vuex'

import GameBox from './GameBox'

export default {
  name: 'GameList',
  data () {
    return {
      itvl: 0,

      games: [],
      gamesLoaded: 0,
      inputID: '',
      querying: false,
      invoking: false
    }
  },
  computed: {
    ...mapState({
      gameCount: state => state.web3.gameCount
    }),
    ...mapGetters({
      address: 'web3/address'
    }),
    inputIDValid () {
      return parseInt(this.inputID).toString() === this.inputID
    }
  },
  mounted () {
    this.update()
    this.itvl = setInterval(() => {
      this.update()
    }, 4000)
  },
  methods: {
    ...mapActions({
      notice: 'notice',
      gameByID: 'web3/gameByID',
      gamesOf: 'web3/gamesOf',
      joinAGame: 'web3/joinAGame'
    }),
    update () {
      setTimeout(() => {
        this.gamesLoaded = this.gamesLoaded || 1
      }, 300)
      this.gamesOf(this.address).then(res => {
        this.games = res
        this.gamesLoaded = 2
      })
    },
    clickGame (game) {
      this.$emit('focus', game)
    },
    queryGame () {
      if (this.querying || !this.inputIDValid) {
        return
      }
      this.querying = true
      this.gameByID(this.inputID).then(res => {
        this.inputID = ''
        this.$emit('focus', res)
        this.querying = false
      })
    },
    join () {
      if (this.invoking) {
        return
      }
      this.invoking = true
      this.joinAGame().then(res => {
        this.invoking = false
        if (res.events) {
          const events = res.events
          if (events.GameCreate) {
            const id = events.GameCreate.returnValues.gameID
            this.notice(['log', `已加入游戏 ID-${id}`, 10000])
          } else if (events.WaitingPlayer) {
            const id = events.WaitingPlayer.returnValues.nextGameID
            this.notice(['log', `已创建游戏 ID-${id} 需等待另一名玩家加入`, 10000])
          }
          this.update()
        } else if (/reverted by the EVM/.test(res.message)) {
          this.notice(['error', `未能创建或参与新游戏 请检查是否已经有一个等待中的游戏`, 10000])
        } else {
          this.notice(['error', `未能创建或参与新游戏 可能是由于网络等原因导致的`, 10000])
        }
      })
    }
  },
  beforeDestroy () {
    clearInterval(this.itvl)
  },
  components: {
    GameBox
  }
}
</script>

<style lang="stylus" scoped>
.game-list-notice
  margin-top 10px
  text-align center
  font-size 14px
  color #666
  border solid 1px #ddd
  border-radius 3px
  padding 10px
  line-height 24px
.game-lists
  display grid
  grid-template-columns repeat(4, 1fr)
  grid-gap 4px
  margin-top 10px
  li
    cursor pointer

.game-search
  margin-top 10px
  display flex
  .game-button
    margin-left 20px
.game-total-count
  float right
  font-size 12px

.game-join
  margin-top 10px

@media screen and (max-width 800px)
  .game-lists
    grid-template-columns repeat(3, 1fr)
@media screen and (max-width 600px)
  .game-lists
    grid-template-columns repeat(2, 1fr)
</style>
