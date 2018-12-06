<template>
  <div class="main-width">
    <div class="game-content game-account">
      <h2>{{$t('Account.current')}}</h2>
      <div>
        <img :src="user.img">
        <span>{{$t(`Account.player[${user.index}]`)}}</span>
      </div>
      <p>
        <span class="key">{{$t('Account.address')}}</span>
        <span class="hash">{{address}}</span>
      </p>
    </div>
    <div class="game-content">
      <h2>{{$t('gamelist')}}</h2>
      <div class="game-create-new" @click="join">{{invoking ? $t('processing') : $t('newgame')}}</div>
      <div class="game-list-notice" v-if="gamesLoaded === 1">{{$t('loading')}}</div>
      <ul class="game-lists" v-else>
        <li v-for="(game, index) in games" :key="index" @click="clickGame(game)" v-if="!game.result">
          <game-box :data="game" />
        </li>
      </ul>
      <h2>{{$t('record')}}</h2>
      <div class="game-list-notice" v-if="gamesLoaded === 1">{{$t('loading')}}</div>
      <ul class="game-lists" v-else>
        <li v-for="(game, index) in games" :key="index" @click="clickGame(game)" v-if="game.result">
          <game-box :data="game" />
        </li>
      </ul>
    </div>
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
      gameLength: 0,
      endGameLength: 0,
      gamesLoaded: 0,
      inputID: '',
      invoking: false
    }
  },
  computed: {
    ...mapState({
      gameCount: state => state.web3.gameCount
    }),
    ...mapGetters({
      user: 'user',
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
    }, 6000)
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
            this.notice(['log', `${this.$t('Gamenotice.join')} ID-${id}`, 10000])
          } else if (events.WaitingPlayer) {
            const id = events.WaitingPlayer.returnValues.nextGameID
            this.notice(['log', `${this.$t('Gamenotice.join')} ID-${id} ${this.$t('Gamenotice.wait')}`, 10000])
          }
          this.update()
        } else if (/reverted by the EVM/.test(res.message)) {
          this.notice(['error', this.$t('Gamenotice.error'), 10000])
        } else {
          this.notice(['error', this.$t('Gamenotice.neterror'), 10000])
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
.main-width
  margin-bottom 100px
h2
  margin 0 0 20px
  font-weight 500
  font-size 20px
  line-height 20px

.game-account
  font-size 18px
  color #333
  div
    margin 30px 0
    display flex
    img
      width 40px
      height 40px
      border-radius 20px
      margin-right 20px
    span
      line-height 40px
  p
    margin 0
    display flex
    line-height 20px
    .key
      flex 0 0 140px
    .hash
      overflow hidden
      text-overflow ellipsis

.game-create-new
  position absolute
  top 30px
  right 30px
  width 150px
  height 40px
  box-sizing border-box
  border-radius 20px
  border solid 1px #999
  color #333
  opacity .6
  line-height 38px
  text-align center
  cursor pointer
  transition opacity .4s
  &:hover
    opacity 1

.game-list-notice
  text-align center
  margin 40px 0
  border solid 1px #dfdfdf
  border-radius 10px
  line-height 100px
  font-size 18px
  color #666

.game-lists
  display grid
  grid-gap 40px
  grid-template-columns repeat(4, 1fr)
  margin 40px 0
  li
    flex 0 0 260px
    cursor pointer

@media screen and (max-width: 1100px)
  .game-lists
    grid-template-columns repeat(3, 1fr)

@media screen and (max-width: 900px)
  .game-lists
    grid-template-columns repeat(2, 1fr)

@media screen and (max-width: 560px)
  .game-lists
    grid-template-columns repeat(1, 1fr)
</style>
