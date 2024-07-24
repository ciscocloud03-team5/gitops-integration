import http from 'k6/http';
import { sleep } from 'k6';
import { check } from 'k6';

export let options = {
  stages: [
    { duration: '45s', target: 2000 }, // ramp up to 20 users
    { duration: '10m', target: 2000 },  // stay at 20 users for 1 minute
    { duration: '30s', target: 0 },  // ramp down to 0 users
  ],
};

export default function () {
  let res = http.get('https://pokerogue.nuschool.store/');
  check(res, {
    'status was 200': (r) => r.status == 200,
  });
  sleep(1);
}
