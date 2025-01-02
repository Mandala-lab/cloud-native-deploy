import Box from '@mui/material/Box'
import {Button, TextField} from '@mui/material'
import SendIcon from '@mui/icons-material/Send'
import {useEffect, useState} from 'react'

type Captcha = {
	captchaId: string
	picPath: string
}

export default function LoginPage() {
	const [captcha, setCaptcha] = useState<Captcha>({
		captchaId: '',
		picPath: '',
	})

	const [mobile, setMobile] = useState<string>('')
	const [pwd, setPwd] = useState<string>('')
	const [captchaInp, setCaptchaInp] = useState<string>('')

	const getCaptcha = () => {
		fetch('http://127.0.0.1:8001/api/users/captcha', {
			method: 'GET',
			headers: {'Content-Type': 'application/json'},
		})
			.then(async data => {
				let res: Captcha = await data.json()
				console.log(res)
				setCaptcha({
					captchaId: res.captchaId,
					picPath: res.picPath,
				})
			})
			.catch(err => console.log(err))
	}

	useEffect(() => {
		getCaptcha()
	}, [])

	const login = (): void => {
		fetch('http://127.0.0.1:8001/api/users/login', {
			method: 'POST',
			headers: {'Content-Type': 'application/json'},
			body: JSON.stringify({
				mobile: mobile,
				password: pwd,
				captcha: captchaInp,
				captchaId: captcha.captchaId,
			}),
		})
			.then(async data => {
				let res = await data.json()
				console.log(res)
			})
			.catch(err => console.log(err))
	}

	return <>
		<Box
			sx={{
				width: '400px',
				bc: '#fff',
				color: '#fff',
			}}
		>
			<TextField
				onChange={(e) => setMobile(e.target.value)}
				id="standard-basic"
				label="mobile"
				variant="standard"
				type="tel"
				// value="13888888881"
				placeholder="mobile"
			/>
		</Box>

		<Box>
			<TextField id="" label="passowrd" variant="standard" type="password" placeholder="password"
								 onChange={(e) => setPwd(e.target.value)} />
		</Box>

		<Box>
			<TextField
				onChange={e => setCaptchaInp(e.target.value)}
				id="standard-basic"
				label="mobile"
				variant="standard"
				type="text"
				placeholder="captcha"
			/>
		</Box>

		<Box>
			<Box
				onClick={() => getCaptcha()}
				component="img"
				src={captcha.picPath}
				alt="captcha"
			/>
		</Box>

		<Box>
			<Button
				onClick={() => login()}
				variant="contained"
				endIcon={<SendIcon />}
			>
				Login
			</Button>
		</Box>
	</>
}
