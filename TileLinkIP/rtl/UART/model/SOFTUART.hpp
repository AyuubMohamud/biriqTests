#include <cstdint>

class SOFTUART {
public:
  SOFTUART(int32_t clock_rate, int32_t baudrate) {
    m_bauddiv = clock_rate / baudrate;
    m_txcycles = 0;
    m_state = UART::INIT;
    m_idx = 0;
    m_rxcycles = 0;
  };
  ~SOFTUART() = default;
  bool recieveEval(bool rx) {
    switch (m_state) {
    case UART::INIT: {
      if (!rx) {
        m_txcycles = 0;
        m_state = UART::START;
      }
      break;
    }
    case UART::START: {
      if (m_txcycles == (m_bauddiv / 2)) {
        m_state = UART::BYTE;
        m_txcycles = 0;
        return false;
      }
      break;
    }
    case UART::BYTE: {
      if (m_txcycles == m_bauddiv - 1) {
        m_rx[m_idx] = rx;
        m_idx++;
        m_txcycles = 0;
        if (m_idx == 8) {
          m_state = UART::STOP;
        }
        return false;
      }
      break;
    }
    case UART::STOP: {
      break;
    }
    }
    m_txcycles++;
    bool m_exit = (m_state == UART::STOP) &&
                  (m_txcycles == (m_bauddiv + (m_bauddiv / 2)));
    if (m_exit) {
      m_txcycles = 0;
      m_state = UART::INIT;
      m_idx = 0;
    }
    return m_exit;
  }
  int8_t recieveValue() {
    char c = 0;
    for (int k = 0; k < 8; k++) {
      c |= (m_rx[k] << k);
    }
    return c;
  }
  void transmitSetup(uint8_t byte) {
    for (int k = 0; k < 8; k++) {
      m_tx[k] = (byte >> k) & 0x1;
    }
  }
  void transmitEval(unsigned char &rx) {
    m_rxcycles++;
    if (m_rxcycles == m_bauddiv && (m_rxidx == -1)) {
      m_rxcycles = 0;
      rx = 0;
      m_rxidx++;
    } else if (m_rxcycles == m_bauddiv && !(m_rxidx == 8)) {
      m_rxcycles = 0;
      rx = m_tx[m_rxidx];
      m_rxidx++;
    } else if (m_rxcycles == m_bauddiv && m_rxidx == 8) {
      m_rxcycles = 0;
      rx = 1;
      m_rxidx = -1;
    }
  }

private:
  typedef enum UART { INIT, START, BYTE, STOP } state_t;
  int m_bauddiv = 0;
  int m_txcycles = 0;
  int m_rxcycles = 0;
  char m_rx[8] = {0, 0, 0, 0, 0, 0, 0, 0};
  char m_tx[8] = {1, 0, 0, 0, 0, 1, 1, 0};
  char m_idx = 0;
  char m_rxidx = -1;
  bool m_rx_val = true;
  state_t m_state = UART::INIT;
};