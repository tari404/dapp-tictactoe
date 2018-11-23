<template>
  <div id="game-mask">
    <div class="game-main" :class="{
      'game-main-active': myTurn
    }">
      <div class="close" @click="close">
        <span/>
        <span/>
      </div>
      <div class="game-main-info">
        <div class="user">
          <div class="image" :style="{ 'background-image': `url(${user.img})` }" :class="{
            'winner': result === 2 && data.result
          }" />
          <div class="info">
            <p>{{$t(`Account.player[${user.index}]`)}}</p>
            <div>
              <div :class="{
                'game-use-o': offensive,
                'game-use-x': !offensive
              }"></div>
              <div class="round" v-if="ownRound && !data.result">{{$t('hold')}}</div>
            </div>
          </div>
        </div>
        <span>VS</span>
        <div class="user" v-if="waiting">
          <div class="image" />
          <div class="info">
            <p>{{$t('Account.waiting')}}</p>
          </div>
        </div>
        <div class="user" v-else>
          <div class="image" :style="{ 'background-image': `url(${opponent.img})` }" :class="{
            'winner': result === 0 && data.result
          }" />
          <div class="info">
            <p>{{$t(`Account.player[${opponent.index}]`)}}</p>
            <div>
              <div :class="{
                'game-use-x': offensive,
                'game-use-o': !offensive
              }"></div>
              <div class="round" v-if="!ownRound && !data.result">{{$t('hold')}}</div>
            </div>
          </div>
        </div>
      </div>
      <div class="game-main-map" :class="{ 'game-main-map-disable': invoking }">
        <span v-for="i in 9" :key="i" :class="{
          'game-grid-active': myTurn && board[i - 1] === '0',
          'game-grid-selected-o': selectGrid === i && data.p1 === address,
          'game-grid-selected-x': selectGrid === i && data.p2 === address,
          'game-main-o': board[i - 1] === '1',
          'game-main-x': board[i - 1] === '2'
        }" @click="clickGrid(i)" />
      </div>
      <div v-if="this.data.result" class="result" :style="{
        'background-image': `url(${require('../assets/result_' + result + '_' + $i18n.locale + '.png')})`
      }"/>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'Game',
  props: ['data'],
  data () {
    return {
      itvl: 0,

      selectGrid: 0,
      invoking: false
    }
  },
  computed: {
    ...mapGetters({
      user: 'user',
      userByAddress: 'userByAddress',
      address: 'web3/address'
    }),
    board () {
      return this.data.board
    },
    waiting () {
      return this.data.p2 === '0x0000000000000000000000000000000000000000'
    },
    offensive () {
      return this.data.p1 === this.address
    },
    ownRound () {
      const round = this.data.board.reduce((sum, value) => {
        if (value === '1') {
          return sum + 1
        } else if (value === '2') {
          return sum - 1
        }
        return sum
      }, 1)
      return round === 2 ^ this.offensive
    },
    opponent () {
      if (this.offensive) {
        return this.userByAddress(this.data.p2)
      } else {
        return this.userByAddress(this.data.p1)
      }
    },
    myTurn () {
      return !this.data.result && this.ownRound && !this.waiting
    },
    result () {
      switch (this.data.result) {
        case 1:
          return this.offensive ? 'victory' : 'defeat'
        case 2:
          return this.offensive ? 'defeat' : 'victory'
        default:
          return 'draw'
      }
    }
  },
  mounted () {
    this.itvl = setInterval(() => {
      this.data.update()
    }, 2000)
  },
  methods: {
    ...mapActions({
      notice: 'notice',
      nextStep: 'web3/nextStep'
    }),
    close () {
      this.$emit('close')
    },
    submitNextStep () {
      this.invoking = true
      const gameID = this.data.id
      const index = this.selectGrid - 1
      this.nextStep({ gameID, index }).then(res => {
        this.invoking = false
        if (res.status) {
          this.selectGrid = 0
          this.notice(['log', this.$t('Notice.success'), 10000])
          this.data.update()
        } else if (/reverted by the EVM/.test(res.message)) {
          this.notice(['error', this.$t('Notice.unknow'), 10000])
        } else {
          this.notice(['error', this.$t('Notice.neterror'), 10000])
        }
      })
    },
    clickGrid (index) {
      if (!this.myTurn || this.board[index - 1] !== '0') {
        return
      }
      this.selectGrid = index
      this.submitNextStep()
    }
  },
  beforeDestroy () {
    clearInterval(this.itvl)
  }
}
</script>

<style lang="stylus" scoped>
#game-mask
  position fixed
  top 0
  left 0
  background-color #0004
  width 100%
  height 100%
  display flex
  align-items center
  z-index 10
.game-main
  margin auto
  padding 40px
  box-sizing border-box
  width 700px
  height 700px
  background-color #fff
  border-radius 10px
  position relative
  .close
    position absolute
    top -40px
    right 0
    width 30px
    height 30px
    box-sizing border-box
    border-radius 15px
    border solid 2px #fff
    cursor pointer
    span
      position absolute
      top 12px
      left 3px
      display block
      height 2px
      width 20px
      background-color #fff
      &:first-child
        transform rotate(45deg)
      &:last-child
        transform rotate(-45deg)

.game-main-active
  .game-main-map
    background-color #c3dff3

.game-main-info
  display flex
  margin-bottom 60px
  .user
    flex 0 0 230px
    display flex
  .user:last-child
    flex-direction row-reverse
    .info
      align-items flex-end
  .image
    width 80px
    height 80px
    background-size contain
    background-color #bfbfbf
    border-radius 40px
  span
    flex 1 1 auto
    text-align center
    font-size 48px
    line-height 80px
    font-weight 500
  .info
    margin 0 18px
    font-size 16px
    color #666
    display flex
    flex-direction column
    justify-content center
    >div
      display flex
  p
    margin 4px 0
    line-height 16px
.winner
  position relative
  &:after
    content ''
    display block
    width 50px
    height 32px
    background-image url('../assets/winner.png')
    background-size contain
    position absolute
    top -28px
    left 16px
.round
  width 74px
  height 30px
  text-align center
  background-color #fc6541
  border-radius 6px
  color #fff
  font-size 18px
  line-height 32px
  font-weight 500
  margin 4px 6px
.game-use-o:before
  content 'O'
  display block
  font-size 30px
  height 30px
  line-height 32px
  margin 4px 0
  color #FC6541
  font-weight 600
.game-use-x:before
  content 'X'
  display block
  font-size 30px
  height 30px
  line-height 32px
  margin 4px 0
  color #0068B7
  font-weight 600

.game-main-map
  margin 10px auto 
  width 440px
  padding 20px
  border-radius 10px
  background-color #eee
  display grid
  grid-template-columns repeat(3, 140px)
  grid-gap 10px
  position relative
  span
    display block
    background-color #fff
    height 140px
    position relative
    &:after
      width 140px
      height 140px
      position absolute
      top 0
      left 0
      font-size 120px
      line-height 154px
      text-align center
      font-weight 500
.game-grid-active
  cursor pointer
  transform-origin bottom
  transition transform .4s
  &:hover
    transform scaleY(.95)
.game-main-map-disable:after
  content ''
  width 100%
  height 100%
  position absolute
  top 0
  left 0
  background-color #fff4
  // text-align center
  // font-size 14px
  // color #000d
.game-grid-selected-o:after
  content 'O'
  color #FC6541
  opacity .4
.game-grid-selected-x:after
  content 'X'
  color #0068B7
  opacity .4
.game-main-o:after
  content 'O'
  color #FC6541
.game-main-x:after
  content 'X'
  color #0068B7

.result
  position absolute
  width 252px
  height 76px
  background-repeat no-repeat
  top -40px
  left 50%
  transform translateX(-50%)
  background-size contain
</style>
